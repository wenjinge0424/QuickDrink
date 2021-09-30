//
//  QDBaseViewController.m
//  quickdrinks
//
//  Created by mojado on 11/28/17.
//  Copyright © 2017 brainyapps. All rights reserved.
//

#import "QDBaseViewController.h"
#import "UITextField+Complete.h"
#import "Util.h"
#import "DBCong.h"

typedef void (^voidCallBack) (void);
typedef BOOL (^boolCallBack) (NSString * str);
typedef BOOL (^idCallBack) (id str);

@interface QDBaseViewController ()
{
    NSMutableArray * m_textfieldArray;
    boolCallBack m_checkBlockFuncArray[20];
    voidCallBack m_successActionArray[20];
    voidCallBack m_failActionArray[20];
    voidCallBack m_defaultActionArray[20];
}

@property (nonatomic, retain) UILabel * m_tableChecker;

@end

@implementation QDBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    for(int i=0;i<20;i++){
        m_checkBlockFuncArray[i] = nil;
        m_successActionArray[i] = nil;
        m_failActionArray[i] = nil;
        m_defaultActionArray[i] = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void) addTextField:(UITextField*) textfield withCheckFunction:(BOOL (^)(NSString* str))checkBlock
    withSuccessAction:(void (^)(void)) successAction
       withFailAction:(void (^)(void)) failAction
    withDefaultAction:(void (^)(void)) defaultAction
{
    if(!m_textfieldArray)
        m_textfieldArray = [NSMutableArray new];
    textfield.delegate = self;
    [m_textfieldArray addObject:textfield];
    
    
    [textfield addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
    
    int index = [m_textfieldArray indexOfObject:textfield];
    m_checkBlockFuncArray[index] = checkBlock;
    m_successActionArray[index] = successAction;
    m_failActionArray[index] = failAction;
    m_defaultActionArray[index] = defaultAction;
}


- (void) addActionField:(UIView*) textfield withCheckFunction:(BOOL (^)(id str))checkBlock
{
    if(!m_textfieldArray)
        m_textfieldArray = [NSMutableArray new];
    [m_textfieldArray addObject:textfield];
    int index = [m_textfieldArray indexOfObject:textfield];
    m_checkBlockFuncArray[index] = checkBlock;
}
- (void) addActionField:(UIView*) textfield withCheckFunction:(BOOL (^)(id str))checkBlock
      withSuccessAction:(void (^)(void)) successAction
         withFailAction:(void (^)(void)) failAction
      withDefaultAction:(void (^)(void)) defaultAction
{
    if(!m_textfieldArray)
        m_textfieldArray = [NSMutableArray new];
    [m_textfieldArray addObject:textfield];
    int index = [m_textfieldArray indexOfObject:textfield];
    m_checkBlockFuncArray[index] = checkBlock;
    m_successActionArray[index] = successAction;
    m_failActionArray[index] = failAction;
    m_defaultActionArray[index] = defaultAction;
}
- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    int index = (int)[m_textfieldArray indexOfObject:textField];
//    if(textField.text.length == 0){
//        voidCallBack default_callback = m_defaultActionArray[index];
//        default_callback();
//    }
    return YES;
}
- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString*  str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    int index = (int)[m_textfieldArray indexOfObject:textField];
    voidCallBack success_callback = m_successActionArray[index];
    voidCallBack fail_callback = m_failActionArray[index];
    voidCallBack default_callback = m_defaultActionArray[index];
    boolCallBack check_callback = m_checkBlockFuncArray[index];
//    if(str.length == 0){
//        default_callback();
//    }
//    else if(str.length > 0){
    
        BOOL res = check_callback(str);
        if(res)
            success_callback();
        else
            fail_callback();
//    }
    return YES;
}

- (void)textFieldChanged:(UITextField *)textField
{
    if (textField.text.length == 0) {
        int index = (int)[m_textfieldArray indexOfObject:textField];
        voidCallBack success_callback = m_successActionArray[index];
        voidCallBack fail_callback = m_failActionArray[index];
        boolCallBack check_callback = m_checkBlockFuncArray[index];
        BOOL res = check_callback(textField.text);
        if(res)
            success_callback();
        else
            fail_callback();
    }
}


- (void) onDone:(void (^)(void)) successAction withFailAction:(void (^)(NSString * message, id tagetView)) failAction
{
    NSMutableArray * m_errorTextFields = [NSMutableArray new];
    for(id textfield in m_textfieldArray){
        int index = (int)[m_textfieldArray indexOfObject:textfield];
        
        if([textfield isKindOfClass:[UITextField class]]){
            boolCallBack check_callback = m_checkBlockFuncArray[index];
            voidCallBack success_callback = m_successActionArray[index];
            voidCallBack fail_callback = m_failActionArray[index];
            NSString * str = ((UITextField*)textfield).text;
            if(!check_callback(str)){
                fail_callback();
                [m_errorTextFields addObject:textfield];
            }else{
                success_callback();
            }
        }else{
            idCallBack check_callback = m_checkBlockFuncArray[index];
            voidCallBack success_callback = m_successActionArray[index];
            voidCallBack fail_callback = m_failActionArray[index];
            if(check_callback(textfield)){
                if(success_callback){
                    success_callback();
                }
            }else{
                if(fail_callback){
                    fail_callback();
                }
                [m_errorTextFields addObject:textfield];
            }
        }
    }
    if(m_errorTextFields.count == 0){
        if (![Util isConnectableInternet]){
            NSString * message = @"Couldn't connect to the Server. Please check your network connection.";
            dispatch_async(dispatch_get_main_queue(), ^{
                failAction(message, nil);
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                successAction();
            });
        }
    }else{
        NSString * message = @"We detected an error. Help me review your answer and try again";
        if(m_errorTextFields.count > 1){
            message = @"We detected a few errors. Help me review your answers and try again.";
        }
        id firstTextfield = [m_errorTextFields firstObject];
        dispatch_async(dispatch_get_main_queue(), ^{
            failAction(message, firstTextfield);
        });
    }
}

- (void) tableChecker:(UITableView*)tablView
{
    if(!self.m_tableChecker){
        self.m_tableChecker = [[UILabel alloc] initWithFrame:tablView.bounds];
        [self.m_tableChecker setFont:[UIFont systemFontOfSize:17]];
        [self.m_tableChecker setTextAlignment:NSTextAlignmentCenter];
        [self.m_tableChecker setText:@"There is no data to show"];
        [tablView addSubview:self.m_tableChecker];
        [self.m_tableChecker setHidden:YES];
    }
    if([tablView numberOfRowsInSection:0] == 0){
        [self.m_tableChecker setHidden:NO];
    }else{
        [self.m_tableChecker setHidden:YES];
    }
}
@end
