//
//  PickerView.m
//  SoftServeDP
//
//  Created by Developer on 2/12/13.
//  Copyright (c) 2013 Bogdan. All rights reserved.
//

#import "PickerView.h"



@implementation PickerView

@synthesize arrRecords,delegate;



-(id)initWithFrame:(CGRect)frame withNSArray:(NSArray *)arrValues{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.arrRecords = arrValues;
    }
    return self;
    
}
-(void)showPicker{
    
    
    
    
    
    self.userInteractionEnabled = TRUE;
    self.backgroundColor = [UIColor clearColor];
    
    copyListOfItems = [[NSMutableArray alloc] init];
    pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0, 200, 320.0, 0.0)];
    
    pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 156, 320, 44)];
    pickerView.showsSelectionIndicator = YES ;
    pickerView.delegate = self;
    pickerView.dataSource = self;
    
    pickerToolbar.barStyle = UIBarStyleDefault;
    [pickerToolbar sizeToFit];
    
    UIBarButtonItem *flexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *btnDone = [[UIBarButtonItem alloc] initWithTitle:@"Далі" style:UIBarButtonItemStyleBordered target:self action:@selector(btnDoneClick)];
    UIColor * btnColor = [UIColor colorWithRed :0.1923 green:0.30 blue:0.4577 alpha:1 ];
    btnDone.tintColor = btnColor;
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    [pickerToolbar addSubview:txtSearch ];
    NSArray *arrBarButtoniTems = [[NSArray alloc] initWithObjects:flexible,btnDone, nil];
    [pickerToolbar setItems:arrBarButtoniTems];
    [self addSubview:pickerView];
    [self addSubview:pickerToolbar];

    
}



-(void)btnDoneClick{
    
    
    [self removeFromSuperview];
    
}


// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    if (searching) {
        return copyListOfItems.count;
    }else{
        return self.arrRecords.count;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    if (searching) {
        return [copyListOfItems objectAtIndex:row];
    }else{
        return [self.arrRecords objectAtIndex:row];
    }
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
}

@end
