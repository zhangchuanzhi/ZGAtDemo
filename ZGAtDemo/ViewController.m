//
//  ViewController.m
//  ZGAtDemo
//
//  Created by offcn_zcz32036 on 2018/5/28.
//  Copyright © 2018年 cn. All rights reserved.
//

#import "ViewController.h"
#import "HPGrowingTextView.h"
#import "ZGCommentCell.h"
#import "ZGSelectUserController.h"
@interface ViewController ()
<HPGrowingTextViewDelegate,UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)HPGrowingTextView *textView;
@property(nonatomic,strong)UITableView*tableView;
@property(nonatomic,strong)NSMutableArray<NSString*>*comments;
@property(nonatomic,strong)UIView *bottomView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self bulidSubViews];
}
-(void)bulidSubViews
{
    UIView *bottomView=[UIView new];
    bottomView.backgroundColor=[UIColor clearColor];
    [self.view addSubview:bottomView];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.offset(0);
        make.height.mas_equalTo(46);
    }];
    self.bottomView=bottomView;
    UIButton*sendBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [sendBtn setTitle:@"@" forState:UIControlStateNormal];
    [sendBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    sendBtn.titleLabel.font=[UIFont systemFontOfSize:17];
    [bottomView addSubview:sendBtn];
    [sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.offset(0);
        make.width.mas_equalTo(55);
    }];
    [sendBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    HPGrowingTextView *textView=[HPGrowingTextView new];
    [bottomView addSubview:textView];
    [textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(10);
        make.centerY.equalTo(bottomView.mas_centerY);
        make.top.offset(7);
        make.bottom.offset(-7);
        make.right.equalTo(sendBtn.mas_left);
    }];
    textView.delegate=self;
    textView.font=[UIFont systemFontOfSize:13];
    textView.minNumberOfLines=1;
    textView.maxNumberOfLines=10;
    textView.placeholder=@"请输入评论";
    textView.returnKeyType=UIReturnKeySend;
    textView.enablesReturnKeyAutomatically=YES;
    textView.backgroundColor=[[UIColor lightGrayColor]colorWithAlphaComponent:0.1];
    self.textView=textView;

    UITableView *tableView=[UITableView new];
    [self.view addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.offset(0);
        make.bottom.equalTo(bottomView.mas_top);
    }];
    tableView.delegate=self;
    tableView.dataSource=self;
    tableView.showsVerticalScrollIndicator=NO;
    tableView.estimatedRowHeight=50;
    tableView.tableFooterView=[UIView new];
    [tableView registerClass:[ZGCommentCell class] forCellReuseIdentifier:NSStringFromClass([ZGCommentCell class])];
    self.tableView=tableView;
    NSString *aComment=@"假数据，一个@和空格之间视为一个艾特，例如@小松哥 ，末尾没有空格的不视为艾特，例@志哥";
    self.comments=[@[aComment]mutableCopy];

}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.comments.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZGCommentCell *cell=[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ZGCommentCell class]) forIndexPath:indexPath];
    cell.comment=self.comments[indexPath.row];
    return cell;
}
#pragma mark -HPGrowingTextViewDelegate
-(void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    [self.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.offset(0);
        make.height.mas_equalTo(height+14);
    }];
}
-(BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView
{
    [self.textView resignFirstResponder];
    return YES;
}
-(BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@""]) {
        NSRange selectRange=growingTextView.selectedRange;
        if (selectRange.length>0) {
            //用户长按选择文本时不处理
            return YES;
        }
        //判断删除的是一个@中间的字符就整体删除
        NSMutableString*string=[NSMutableString stringWithString:growingTextView.text];
        NSArray*matches=[self findAllAt];
        BOOL inAt=NO;
        NSInteger index=range.location;
        for (NSTextCheckingResult*match in matches) {
            NSRange newRange=NSMakeRange(match.range.location+1, match.range.length-1);
            if (NSLocationInRange(range.location, newRange)) {
                inAt=YES;
                index=match.range.location;
                [string replaceCharactersInRange:match.range withString:@""];
                break;
            }
        }
        if (inAt) {
            growingTextView.text=string;
            growingTextView.selectedRange=NSMakeRange(index, 0);
            return NO;
        }
    }
    //判断是回车键就发送出去
    if ([text isEqualToString:@"\n"]) {
        [self.comments addObject:growingTextView.text];
        self.textView.text=@"";
        [self.textView resignFirstResponder];
        [self.tableView reloadData];
        return NO;
    }
    return YES;
}
-(void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView
{
    UITextRange *selectedRange=growingTextView.internalTextView.markedTextRange;
    NSString*newText=[growingTextView.internalTextView textInRange:selectedRange];
    if (newText.length<1) {
        //高亮输入框中的@
        UITextView*textView=self.textView.internalTextView;
        NSRange range=textView.selectedRange;
        NSMutableAttributedString*string=[[NSMutableAttributedString alloc]initWithString:textView.text];
        [string addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, string.string.length)];
        NSArray *matches=[self findAllAt];
        for (NSTextCheckingResult*match in matches) {
            [string addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(match.range.location, match.range.length-1)];
        }
        textView.attributedText=string;
        textView.selectedRange=range;
    }
}
-(NSArray<NSTextCheckingResult*>*)findAllAt
{
    //找到文本中所有的@
    NSString*string=self.textView.text;
    NSRegularExpression*regex=[NSRegularExpression regularExpressionWithPattern:kATRegular options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray*matches=[regex matchesInString:string options:NSMatchingReportProgress range:NSMakeRange(0, string.length)];
    return matches;
}
-(void)growingTextViewDidChangeSelection:(HPGrowingTextView *)growingTextView
{
    //光标不能点落在@词中间
    NSRange range=growingTextView.selectedRange;
    if (range.length>0) {
        //选择文本时可以
        return;
    }
    NSArray*matches=[self findAllAt];
    for (NSTextCheckingResult*match in matches) {
        NSRange newRange=NSMakeRange(match.range.location+1, match.range.length-1);
        if (NSLocationInRange(range.location, newRange)) {
            growingTextView.internalTextView.selectedRange=NSMakeRange(match.range.location+match.range.length, 0);
            break;
        }
    }
}
-(void)btnClick:(UIButton*)sender
{
    //去选择@的人
    [self.textView.internalTextView unmarkText];
    NSInteger index=self.textView.text.length;
    if (self.textView.isFirstResponder) {
        index=self.textView.selectedRange.location+self.textView.selectedRange.length;
        [self.textView resignFirstResponder];
    }
    ZGSelectUserController *userVC=[ZGSelectUserController new];
    userVC.SelectUserBlock = ^(NSString *name) {
        UITextView*textView=self.textView.internalTextView;
        NSString*insertString=[NSString stringWithFormat:kATFormat,name];
        NSMutableString*string=[NSMutableString stringWithString:textView.text];
        [string insertString:insertString atIndex:index];
        self.textView.text=string;
        [self.textView becomeFirstResponder];
        textView.selectedRange=NSMakeRange(index+insertString.length, 0);
    };
    [self.navigationController pushViewController:userVC animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}


@end
