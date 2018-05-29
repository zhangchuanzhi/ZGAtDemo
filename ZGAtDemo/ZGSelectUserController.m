//
//  ZGSelectUserController.m
//  ZGAtDemo
//
//  Created by offcn_zcz32036 on 2018/5/28.
//  Copyright © 2018年 cn. All rights reserved.
//

#import "ZGSelectUserController.h"

@interface ZGSelectUserController ()
<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)UITableView*tableView;
@end

@implementation ZGSelectUserController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self buildSubViews];
}
-(void)buildSubViews
{
    UITableView*tableView=[[UITableView alloc]initWithFrame:CGRectZero];
    tableView.delegate=self;
    tableView.dataSource=self;
    tableView.estimatedRowHeight=44;
    tableView.tableFooterView=[UIView new];
    tableView.showsVerticalScrollIndicator=NO;
    [self.view addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    self.tableView=tableView;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId=@"cell";
    UITableViewCell*cell=[tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.textLabel.text=[NSString stringWithFormat:@"用户%ld",indexPath.row];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell*cell=[tableView cellForRowAtIndexPath:indexPath];
    if (self.SelectUserBlock) {
        self.SelectUserBlock(cell.textLabel.text);
    }
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}


@end
