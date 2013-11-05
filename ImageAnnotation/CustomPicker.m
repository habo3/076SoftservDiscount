//
//  CustomPicker.m
//  SoftServeDP
//
//  Created by Mykola on 2/18/13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//
# define TOOLBAR_HEIGHT 44.0

#import "CustomPicker.h"

@interface CustomPicker()
@property (nonatomic) CGSize viewSize;
@property (nonatomic,retain) NSArray *data;
@property (nonatomic,assign) NSInteger selectedIndex;
@property (nonatomic, retain) NSObject *selfReference;
@end

@implementation CustomPicker

@synthesize data = _data;
@synthesize selectedIndex = _selectedIndex;
@synthesize viewSize = _viewSize;
@synthesize successAction = _successAction;
@synthesize actionSheet = _actionSheet;
@synthesize pickerView = _pickerView;
@synthesize target = _target;
@synthesize selfReference = _selfReference;

#pragma mark - PickerInit

+ (id)showPickerWithRows:(NSArray *)data initialSelection:(NSInteger)index target:(id)target successAction:(SEL)successAction {
    CustomPicker *picker = [[CustomPicker alloc] initWithRows:data initialSelection:index target:target successAction:successAction];
    [picker showCustomPicker];
    return picker;
}

- (id)initWithRows:(NSArray *)data initialSelection:(NSInteger)index target:(id)target successAction:(SEL)successAction
{
    self = [super init];
    self.viewSize = CGSizeMake(320,500);
    self.target = target;
    self.successAction = successAction;
    self.data = data;
    self.selectedIndex = index;
    self.selfReference = self;
    return self;
}

#pragma mark - UIPickerViewDelegate / DataSource

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.selectedIndex = row;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.data.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self.data objectAtIndex:row];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return pickerView.frame.size.width - 30;
}

#pragma mark - Actions

- (void)showCustomPicker {
    UIView *masterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.viewSize.width, self.viewSize.height)];
    UIToolbar *pickerToolbar = [self createPickerToolbar];
    [pickerToolbar setBarStyle:UIBarStyleBlackTranslucent];
    [masterView addSubview:pickerToolbar];
    self.pickerView = [self configuredPickerView];
    [masterView addSubview:_pickerView];
    [self configureAndPresentActionSheetForView:masterView];
}

- (IBAction)actionPickerDone:(id)sender {
    [self notifyTarget:self.target didSucceedWithAction:self.successAction];
    [self dismissPicker];
}

- (void)dismissPicker {
    [_actionSheet dismissWithClickedButtonIndex:0 animated:YES];
    self.actionSheet = nil;
    self.selfReference = nil;
}


- (UIToolbar *)createPickerToolbar {
    
    //Toolbar
    CGRect frame = CGRectMake(0, 0, self.viewSize.width, TOOLBAR_HEIGHT);
    UIToolbar *pickerToolbar = [[UIToolbar alloc] initWithFrame:frame]; 
    pickerToolbar.barStyle = UIBarStyleBlackTranslucent;
    
    //ToolbarButtons
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                               target:nil
                                                                               action:nil];
    [barItems addObject:flexSpace];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Далі"
                                                                style:UIBarButtonItemStyleBordered
                                                               target:self
                                                               action:@selector(actionPickerDone:)];
    UIColor * doneButtonColor = [UIColor colorWithRed :0.2 green:0.30 blue:0.46 alpha:1.0 ];
    doneButton.tintColor = doneButtonColor;
    [barItems addObject:doneButton];
    
    //Set buttons on toolbar
    [pickerToolbar setItems:barItems];
    return pickerToolbar;
}

- (void)configureAndPresentActionSheetForView:(UIView *)aView {
    
    _actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    [_actionSheet addSubview:aView];
    [_actionSheet showFromBarButtonItem:_target animated:YES];
    _actionSheet.bounds = CGRectMake(0, 0, self.viewSize.width, self.viewSize.height);
}

- (UIView *)configuredPickerView {
    CGRect pickerFrame = CGRectMake(0, TOOLBAR_HEIGHT, self.viewSize.width, self.viewSize.height);
    UIPickerView *stringPicker = [[UIPickerView alloc] initWithFrame:pickerFrame]; 
    stringPicker.delegate = self;
    stringPicker.dataSource = self;
    stringPicker.showsSelectionIndicator = YES;
    [stringPicker selectRow:self.selectedIndex inComponent:0 animated:NO];
    return stringPicker;
}

#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

- (void)notifyTarget:(id)target didSucceedWithAction:(SEL)successAction
{
    if (target && [target respondsToSelector:successAction]) {
        [target performSelector:successAction withObject:[NSNumber numberWithInt:self.selectedIndex] withObject:nil];
    }
}

#pragma mark - dealloc

- (void)dealloc {
    
    if ([self.pickerView respondsToSelector:@selector(setDelegate:)])
        [self.pickerView performSelector:@selector(setDelegate:) withObject:nil];
    
    if ([self.pickerView respondsToSelector:@selector(setDataSource:)])
        [self.pickerView performSelector:@selector(setDataSource:) withObject:nil];
    
    self.pickerView = nil;
    self.target = nil;
}

@end