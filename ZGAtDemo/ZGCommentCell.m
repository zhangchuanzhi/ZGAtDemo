//
//  ZGCommentCell.m
//  ZGAtDemo
//
//  Created by offcn_zcz32036 on 2018/5/29.
//  Copyright © 2018年 cn. All rights reserved.
//

#import "ZGCommentCell.h"
#import "MLLinkLabel.h"
@interface ZGCommentCell()
@property(nonatomic,strong)MLLinkLabel*titleLabel;
@end
@implementation ZGCommentCell

- (void)awakeFromNib {
    [super awakeFromNib];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self bulidSubViews];
    }
    return self;
}
-(void)bulidSubViews
{
    self.selectionStyle=UITableViewCellSelectionStyleNone;
    MLLinkLabel*titleLabel=[MLLinkLabel new];
    [self.contentView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(15);
        make.top.offset(5);
        make.bottom.offset(-5);
        make.right.offset(-15);
    }];
    titleLabel.dataDetectorTypes=MLDataDetectorTypeNone;
    titleLabel.lineSpacing=2;
    titleLabel.numberOfLines=0;
    titleLabel.linkTextAttributes=@{NSForegroundColorAttributeName:[UIColor redColor]};
    titleLabel.didClickLinkBlock = ^(MLLink *link, NSString *linkText, MLLinkLabel *label) {
        NSLog(@"%@",linkText);
    };
    self.titleLabel=titleLabel;
}
-(void)setComment:(NSString *)comment
{
    _comment=comment;
    self.titleLabel.text=comment;
    //高亮@
    NSRegularExpression*regex=[NSRegularExpression regularExpressionWithPattern:kATRegular options:NSRegularExpressionCaseInsensitive error:nil];
    [regex enumerateMatchesInString:comment options:NSMatchingReportProgress range:NSMakeRange(0, comment.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        [self.titleLabel addLinkWithType:MLLinkTypeUserHandle value:comment range:result.range];
    }];
}
@end
