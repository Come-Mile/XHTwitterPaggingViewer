//
//  XHTwitterPaggingViewer.m
//  XHTwitterPagging
//
//  Created by 曾 宪华 on 14-6-20.
//  Copyright (c) 2014年 曾宪华 QQ群: (142557668) QQ:543413507  Gmail:xhzengAIB@gmail.com. All rights reserved.
//

#import "XHTwitterPaggingViewer.h"

#import "XHPaggingNavbar.h"

@interface XHTwitterPaggingViewer () <UIScrollViewDelegate>

/**
 *  显示内容的容器
 */
@property (nonatomic, strong) UIScrollView *paggingScrollView;

/**
 *  显示title集合的容器
 */
@property (nonatomic, strong) XHPaggingNavbar *paggingNavbar;

/**
 *  标识当前页码
 */
@property (nonatomic, assign) NSInteger currentPage;

@end

@implementation XHTwitterPaggingViewer

#pragma mark - DataSource

- (NSInteger)getCurrentPageIndex {
    return self.currentPage;
}

- (void)reloadData {
    if (!self.viewControllers.count) {
        return;
    }
    
    [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController *viewController, NSUInteger idx, BOOL *stop) {
        CGRect contentViewFrame = viewController.view.bounds;
        contentViewFrame.origin.x = idx * CGRectGetWidth(self.view.bounds);
        viewController.view.frame = contentViewFrame;
        [self.paggingScrollView addSubview:viewController.view];
        [self addChildViewController:viewController];
    }];

    [self.paggingScrollView setContentSize:CGSizeMake(CGRectGetWidth(self.view.bounds) * self.viewControllers.count, 0)];
    
    self.paggingNavbar.titles = [self.viewControllers valueForKey:@"title"];
    [self.paggingNavbar reloadData];
    
    [self setupScrollToTop];
    
    [self callBackChangedPage];
}

#pragma mark - Propertys

- (UIScrollView *)paggingScrollView {
    if (!_paggingScrollView) {
        _paggingScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        _paggingScrollView.bounces = NO;
        _paggingScrollView.pagingEnabled = YES;
        [_paggingScrollView setScrollsToTop:NO];
        _paggingScrollView.delegate = self;
        _paggingScrollView.showsVerticalScrollIndicator = NO;
        _paggingScrollView.showsHorizontalScrollIndicator = NO;
    }
    return _paggingScrollView;
}

- (XHPaggingNavbar *)paggingNavbar {
    if (!_paggingNavbar) {
        _paggingNavbar = [[XHPaggingNavbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds) / 2.0, 44)];
        _paggingNavbar.backgroundColor = [UIColor clearColor];
    }
    return _paggingNavbar;
}

- (UIViewController *)getPageViewControllerAtIndex:(NSInteger)index {
    if (index < self.viewControllers.count) {
        return self.viewControllers[index];
    } else {
        return nil;
    }
}

- (void)setCurrentPage:(NSInteger)currentPage {
    if (_currentPage == currentPage)
        return;
    _currentPage = currentPage;
    
    self.paggingNavbar.currentPage = currentPage;
    
    [self setupScrollToTop];
    [self callBackChangedPage];
}

#pragma mark - Life Cycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupNavigationBar];
    
    [self setupViews];
    
    [self reloadData];
}

- (void)setupNavigationBar {
    if ([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)]) {
        [self setAutomaticallyAdjustsScrollViewInsets:NO];
        [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0.291 green:0.607 blue:1.000 alpha:1.000]];
    } else {
        [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:0.291 green:0.607 blue:1.000 alpha:1.000]];
    }
    
    self.navigationItem.titleView = self.paggingNavbar;
}

- (void)setupViews {
    [self.view addSubview:self.paggingScrollView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    self.paggingScrollView.delegate = nil;
    self.paggingScrollView = nil;
    
    self.paggingNavbar = nil;
    
    self.viewControllers = nil;
    
    self.didChangedPageCompleted = nil;
}

#pragma mark - Block Call Back Method

- (void)callBackChangedPage {
    if (self.didChangedPageCompleted) {
        self.didChangedPageCompleted(self.currentPage, [[self.viewControllers valueForKey:@"title"] objectAtIndex:self.currentPage]);
    }
}

#pragma mark - TableView Helper Method

- (void)setupScrollToTop {
    for (int i = 0; i < self.viewControllers.count; i ++) {
        UITableView *tableView = (UITableView *)[self subviewWithClass:[UITableView class] onView:[self getPageViewControllerAtIndex:i].view];
        if (tableView) {
            if (self.currentPage == i) {
                [tableView setScrollsToTop:YES];
            } else {
                [tableView setScrollsToTop:NO];
            }
        }
    }
}

#pragma mark - View Helper Method

- (UIView *)subviewWithClass:(Class)cuurentClass onView:(UIView *)view {
    for (UIView *subView in view.subviews) {
        if ([subView isKindOfClass:cuurentClass]) {
            return subView;
        }
    }
    return nil;
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.paggingNavbar.contentOffset = scrollView.contentOffset;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // 得到每页宽度
    CGFloat pageWidth = scrollView.frame.size.width;
    
    // 根据当前的x坐标和页宽度计算出当前页数
    self.currentPage = floor((scrollView.contentOffset.x - pageWidth/ 2) / pageWidth)+ 1;
}

@end
