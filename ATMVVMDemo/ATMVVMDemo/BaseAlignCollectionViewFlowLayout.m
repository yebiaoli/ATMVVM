//
//  BaseAlignCollectionViewFlowLayout.m
//  BaseModule
//
//  Created by TingtingLi on 2019/12/2.
//

#import "BaseAlignCollectionViewFlowLayout.h"

@interface BaseAlignCollectionViewFlowLayout () {
    //在居中对齐的时候需要知道这行所有cell的宽度总和
    CGFloat _sumCellWidth ;
}

@end

@implementation BaseAlignCollectionViewFlowLayout

- (instancetype)initWithCoder:(NSCoder *)coder
{
    return [self initWithType:AlignWithLeft];
}

- (instancetype)init {
    return [self initWithType:AlignWithLeft];
}

- (instancetype)initWithType:(AlignType)cellType {
    self = [super init];
    if (self){
        _cellType = cellType;
    }
    return self;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray * layoutAttributes_t = [super layoutAttributesForElementsInRect:rect];
    NSArray * layoutAttributes = [[NSArray alloc]initWithArray:layoutAttributes_t copyItems:YES];
    //用来临时存放一行的Cell数组
    NSMutableArray * layoutAttributesTemp = [[NSMutableArray alloc]init];
    for (NSUInteger index = 0; index < layoutAttributes.count ; index++) {
        
        UICollectionViewLayoutAttributes *currentAttr = layoutAttributes[index]; // 当前cell的位置信息
        UICollectionViewLayoutAttributes *previousAttr = index == 0 ? nil : layoutAttributes[index-1]; // 上一个cell的位置信息
        UICollectionViewLayoutAttributes *nextAttr = index + 1 == layoutAttributes.count ?
        nil : layoutAttributes[index+1];//下一个cell的位置信息
        
        //加入临时数组
        [layoutAttributesTemp addObject:currentAttr];
        _sumCellWidth += currentAttr.frame.size.width;
        
        CGFloat previousY = previousAttr == nil ? 0 : CGRectGetMaxY(previousAttr.frame);
        CGFloat currentY = CGRectGetMaxY(currentAttr.frame);
        CGFloat nextY = nextAttr == nil ? 0 : CGRectGetMaxY(nextAttr.frame);
        //如果当前cell是单独一行
        if (currentY != previousY && currentY != nextY){
            if ([currentAttr.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
                [layoutAttributesTemp removeAllObjects];
                _sumCellWidth = 0.0;
            }else if ([currentAttr.representedElementKind isEqualToString:UICollectionElementKindSectionFooter]){
                [layoutAttributesTemp removeAllObjects];
                _sumCellWidth = 0.0;
            }else{
                [self setCellFrameWith:layoutAttributesTemp];
            }
        }
        //如果下一个cell在本行，这开始调整Frame位置
        else if( currentY != nextY) {
            [self setCellFrameWith:layoutAttributesTemp];
        }
    }
    return layoutAttributes;
}

//调整属于同一行的cell的位置frame
- (void)setCellFrameWith:(NSMutableArray*)layoutAttributes {
    CGFloat nowWidth = 0.0;
    switch (_cellType) {
        case AlignWithLeft:
            nowWidth = self.sectionInset.left;
            for (UICollectionViewLayoutAttributes * attributes in layoutAttributes) {
                CGRect nowFrame = attributes.frame;
                nowFrame.origin.x = nowWidth;
                attributes.frame = nowFrame;
                nowWidth += nowFrame.size.width + self.minimumInteritemSpacing;
            }
            _sumCellWidth = 0.0;
            [layoutAttributes removeAllObjects];
            break;
            
        case AlignWithCenter:
            nowWidth = (self.collectionView.frame.size.width - _sumCellWidth - ((layoutAttributes.count - 1) * self.minimumInteritemSpacing)) / 2;
            for (UICollectionViewLayoutAttributes * attributes in layoutAttributes) {
                CGRect nowFrame = attributes.frame;
                nowFrame.origin.x = nowWidth;
                attributes.frame = nowFrame;
                nowWidth += nowFrame.size.width + self.minimumInteritemSpacing;
            }
            _sumCellWidth = 0.0;
            [layoutAttributes removeAllObjects];
            break;
            
        case AlignWithRight:
            nowWidth = self.collectionView.frame.size.width - self.sectionInset.right;
            for (NSInteger index = layoutAttributes.count - 1 ; index >= 0 ; index-- ) {
                UICollectionViewLayoutAttributes * attributes = layoutAttributes[index];
                CGRect nowFrame = attributes.frame;
                nowFrame.origin.x = nowWidth - nowFrame.size.width;
                attributes.frame = nowFrame;
                nowWidth = nowWidth - nowFrame.size.width - self.minimumInteritemSpacing;
            }
            _sumCellWidth = 0.0;
            [layoutAttributes removeAllObjects];
            break;
    }
}


@end
