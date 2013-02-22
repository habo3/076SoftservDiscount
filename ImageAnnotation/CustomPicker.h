//
//  CustomPicker.h
//  SoftServeDP
//
//  Created by Mykola on 2/18/13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//

@interface CustomPicker : NSObject<UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, assign) id target;
@property (nonatomic, assign) SEL successAction;
@property (nonatomic, retain) UIActionSheet *actionSheet;
@property (nonatomic, retain) UIView *pickerView;
@property (nonatomic, readonly) CGSize viewSize;

+ (id)showPickerWithRows:(NSArray *)data initialSelection:(NSInteger)index target:(id)target successAction:(SEL)successAction;

- (id)initWithRows:(NSArray *)data initialSelection:(NSInteger)index target:(id)target successAction:(SEL)successAction;

- (void)showCustomPicker;

- (void)notifyTarget:(id)target didSucceedWithAction:(SEL)successAction;

- (UIPickerView *)configuredPickerView;

- (void)configureAndPresentActionSheetForView:(UIView *)aView;

- (void)dismissPicker;

- (UIToolbar *)createPickerToolbar;

- (IBAction)actionPickerDone:(id)sender;

@end