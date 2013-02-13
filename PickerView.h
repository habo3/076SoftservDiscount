//
//  PickerView.h
//  SoftServeDP
//
//  Created by Developer on 2/12/13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PickerViewDelegate <NSObject>


@end
@interface PickerView : UIView<UIActionSheetDelegate,UIPickerViewDataSource,UIPickerViewDelegate>{
    
    UIPickerView *pickerView;
    UIToolbar *pickerToolbar;
    UISearchBar *txtSearch;
    NSArray *arrRecords;
    UIActionSheet *aac;
    
    NSMutableArray *copyListOfItems;
    BOOL searching;
	BOOL letUserSelectRow;
    
    id <PickerViewDelegate> delegate;
    
}


@property (nonatomic, retain) NSArray *arrRecords;
@property (nonatomic, retain) id <PickerViewDelegate> delegate;

-(id)initWithFrame:(CGRect)frame withNSArray:(NSArray *)arrValues;
-(void)showPicker;
-(void)btnDoneClick;
@end
