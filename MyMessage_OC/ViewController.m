//
//  ViewController.m
//  MyMessage_OC
//
//  Created by dixon on 16/6/29.
//  Copyright © 2016年 Monaco1. All rights reserved.
//

#import "ViewController.h"
#import <BRAOfficeDocumentPackage.h>
#import "Contacts.h"
#import <MRProgress.h>
#import <AddressBook/AddressBook.h>

@interface ViewController ()
@property(readwrite)NSMutableArray *contactsArray;
@property(readwrite)ABAddressBookRef addressBook;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _contactsArray = [[NSMutableArray alloc]init];
    
    NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
    if ([u objectForKey:@"contacts"]) {
        NSData *data = [u objectForKey:@"contacts"];
        _contactsArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [tv reloadData];
    }
    
    [self setTitle:@"联系人"];
    
    [self requestAddressBook];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(add:) name:@"Notice3DTouch" object:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    if (self.addressBook != NULL) {
        CFRelease(self.addressBook);
    }
}

//message delegate
-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    switch (result) {
        case MessageComposeResultSent:
            
            break;
        case MessageComposeResultFailed:
            
            break;
        case MessageComposeResultCancelled:
            
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:true completion:nil];
}

//tableview delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_contactsArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    Contacts *c = [_contactsArray objectAtIndex:[indexPath row]];
    [cell.textLabel setText:[c name]];
    
    if ([c isSelect]) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }else{
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Contacts *c = [_contactsArray objectAtIndex:[indexPath row]];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([c isSelect]) {
        [c setIsSelect:false];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }else{
        [c setIsSelect:true];
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_contactsArray removeObjectAtIndex:[indexPath row]];
    [tv reloadData];
    
    NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_contactsArray];
    [u setObject:data forKey:@"contacts"];
    
    [u synchronize];
}

//addressbook delegate
-(void)requestAddressBook{
    //创建通讯录对象
    self.addressBook=ABAddressBookCreateWithOptions(NULL, NULL);
    
    //请求访问用户通讯录,注意无论成功与否block都会调用
    ABAddressBookRequestAccessWithCompletion(self.addressBook, ^(bool granted, CFErrorRef error) {
        if (!granted) {
            UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"提示" message:@"如要打开权限,请到设置->隐私->通讯录,然后找到本应用并打开" preferredStyle:UIAlertControllerStyleAlert];
            [ac addAction:[UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }]];
            [self presentViewController:ac animated:YES completion:nil];
        }
        
    });
}

//click method
-(IBAction)add:(id)sender
{
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"添加新联系人" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [ac addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.placeholder = @"联系号码/电邮地址";
        textField.keyboardType = UIKeyboardTypeEmailAddress;
    }];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"添加" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        
        
        UITextField *tf_contacts = ac.textFields.firstObject;
        
        if ([[tf_contacts text]length]==0) {
            UIAlertController *avc = [UIAlertController alertControllerWithTitle:@"提示" message:@"请输入联系号码/电邮地址." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [avc addAction:action];
            
            [self presentViewController:avc animated:true completion:nil];
            
        }else{
            
            MRProgressOverlayView *overlayer = [MRProgressOverlayView showOverlayAddedTo:self.view animated:YES];
            
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
            
            dispatch_async(queue, ^{
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyyMMdd"];
                
                NSTimeInterval timeStamp = [[NSDate date]timeIntervalSince1970];
                NSDate *today = [NSDate dateWithTimeIntervalSince1970:timeStamp];
                NSString *dateString = [formatter stringFromDate:today];
                NSString *count = [NSString stringWithFormat:@"%lu",([_contactsArray count]+1)];
                NSString *name = [NSString stringWithFormat:@"%@%@",dateString,count];
                
                Contacts *c = [[Contacts alloc]initWithName:name contactAddress:tf_contacts.text];
                [_contactsArray addObject:c];
                
                [tv reloadData];
                
                [self addContactsWithContactAddress:c.contactAddress name:c.name];
                
                NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_contactsArray];
                [u setObject:data forKey:@"contacts"];
                
                [u synchronize];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [overlayer dismiss:YES];
                });
            });
            
            
            
        }
        
        
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        UITextField *tf_contacts = ac.textFields.firstObject;
        [tf_contacts resignFirstResponder];
    }];
    [ac addAction:action];
    [ac addAction:cancel];
    [self presentViewController:ac animated:true completion:nil];
    
}

-(IBAction)send:(id)sender
{
    if ([MFMessageComposeViewController canSendText]) {
        
        NSMutableArray *recipients = [[NSMutableArray alloc]init];
        for (int i = 0 ; i < [_contactsArray count]; i++) {
            Contacts *c = [_contactsArray objectAtIndex:i];
            if ([c isSelect]) {
                [recipients addObject:c.contactAddress];
            }
        }
        MFMessageComposeViewController *messageVC = [[MFMessageComposeViewController alloc]init];
        messageVC.recipients = recipients;
        messageVC.messageComposeDelegate = self;
        
        [self presentViewController:messageVC animated:YES completion:nil];
    }else{
        
        UIAlertController *avc = [UIAlertController alertControllerWithTitle:@"提示" message:@"此设备不支持此功能" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [avc addAction:action];
        
        [self presentViewController:avc animated:true completion:nil];
    }
    
}

-(IBAction)importXLSXFile:(id)sender
{
    
    MRProgressOverlayView *overlayer = [MRProgressOverlayView showOverlayAddedTo:self.view animated:YES];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    
    //BRAOfficeDocumentPackage *spreadsheet = [BRAOfficeDocumentPackage open:[[NSBundle mainBundle]pathForResource:@"haha2" ofType:@"xlsx"]];
    
    //document all file name
    NSArray *filename = [self getFilenamelistOfType:@"xlsx" fromDirPath:path];
    
    if ([filename count]!=0) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
        dispatch_async(queue, ^{
        
            for (int i = 0 ; i < [filename count]; i++) {
                
                NSString *smallPath = [NSString stringWithFormat:@"/%@",[filename objectAtIndex:i]];
                BRAOfficeDocumentPackage *spreadsheet = [BRAOfficeDocumentPackage open:[path stringByAppendingString:smallPath]];
                BRAWorksheet *firstWorksheet = spreadsheet.workbook.worksheets[0];
                
                for (int j = 1 ; j < [[firstWorksheet cells]count] ; j++) {
                    BRACell *cell = [[firstWorksheet cells]objectAtIndex:j];
                    
                    NSString *string = [[firstWorksheet cellForCellReference:cell.reference] stringValue];
                    if ([self isValidateEmail:string]) {
                        
                        
                    }else{
                        
                        long double orderSum = [[NSString stringWithFormat:@"%@",[[firstWorksheet cellForCellReference:cell.reference]stringValue]] doubleValue];
                        NSNumberFormatter * formatter = [[NSNumberFormatter alloc]init];
                        formatter.numberStyle = NSNumberFormatterNoStyle;
                        NSString * tempStr = [formatter stringFromNumber:[NSNumber numberWithDouble:orderSum]];
                        string = [NSString stringWithFormat:@"+%@",tempStr];
                    }
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"yyyyMMdd"];
                    
                    NSTimeInterval timeStamp = [[NSDate date]timeIntervalSince1970];
                    NSDate *today = [NSDate dateWithTimeIntervalSince1970:timeStamp];
                    NSString *dateString = [formatter stringFromDate:today];
                    NSString *count = [NSString stringWithFormat:@"%lu",([_contactsArray count]+1)];
                    NSString *name = [NSString stringWithFormat:@"%@%@",dateString,count];
                    
                    Contacts *c = [[Contacts alloc]initWithName:name contactAddress:string];
                    
                    [_contactsArray addObject:c];
                    NSLog(@"xxx = %lu",[_contactsArray count]);
                    
                    [self addContactsWithContactAddress:c.contactAddress name:c.name];
                    
                }
                
                [self deleteFileWithName:[filename objectAtIndex:i]];
                
                NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_contactsArray];
                [u setObject:data forKey:@"contacts"];
                
                [u synchronize];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [overlayer dismiss:YES];
                });
            }
            
        });
        
    }else{
        
        UIAlertController *avc = [UIAlertController alertControllerWithTitle:@"提示" message:@"没有任何文件,请通过itunes导入xlsx文件" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [avc addAction:action];
        
        [self presentViewController:avc animated:true completion:nil];
        
    }
    
    [tv reloadData];
    [overlayer dismiss:YES];
    
    
}

-(IBAction)moreOption:(id)sender
{
    BOOL isSelectAll = NO;
    
    for (Contacts *c in _contactsArray) {
        if (!c.isSelect) {
            break;
        }
        isSelectAll = YES;
    }
    
    NSString *title = isSelectAll?@"取消全选":@"全选";
    
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"更多选项" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *selectAllAction = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if ([action.title isEqualToString:@"全选"]) {
            
            for (Contacts *c in _contactsArray) {
                c.isSelect = YES;
            }
        }else {
            
            for (Contacts *c in _contactsArray) {
                c.isSelect = NO;
            }

        }
        dispatch_async(dispatch_get_main_queue(), ^{
            // code here
            [tv reloadData];
        });
        
    }];
    
    UIAlertAction *importAction = [UIAlertAction actionWithTitle:@"导入" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self importXLSXFile:nil];
    }];
    
    UIAlertAction *addAction = [UIAlertAction actionWithTitle:@"添加" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self add:nil];
    }];
    
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSMutableArray *temp = [NSMutableArray arrayWithArray:_contactsArray];
        
        for (int i = 0 ; i < temp.count ; i++) {
            Contacts *c = [temp objectAtIndex:i];
            if (c.isSelect) {
                [_contactsArray removeObject:c];
                
                [self deleteAddressbookWithName:c.name];
            }
        }
        
        [tv reloadData];
       
        NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_contactsArray];
        [u setObject:data forKey:@"contacts"];
        
        [u synchronize];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [ac addAction:selectAllAction];
    [ac addAction:importAction];
    [ac addAction:addAction];
    [ac addAction:deleteAction];
    [ac addAction:cancelAction];
    [self presentViewController:ac animated:YES completion:nil];
}

-(void)addContactsWithContactAddress:(NSString*)contactAddress name:(NSString*)name
{
    ABRecordRef recordRef= ABPersonCreate();
    ABRecordSetValue(recordRef, kABPersonFirstNameProperty, (__bridge CFTypeRef)(name), NULL);//添加名
    //ABRecordSetValue(recordRef, kABPersonLastNameProperty, (__bridge CFTypeRef)(@"wong"), NULL);//添加姓
    
    ABMutableMultiValueRef multiValueRef =ABMultiValueCreateMutable(kABStringPropertyType);//添加设置多值属性
    
    if ([self isValidateEmail:contactAddress]) {
        
        ABMutableMultiValueRef emailMultiValue = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABMultiValueAddValueAndLabel(emailMultiValue, (__bridge CFTypeRef)(contactAddress), kABWorkLabel, NULL);
        ABRecordSetValue(recordRef, kABPersonEmailProperty, emailMultiValue, nil);
        CFRelease(emailMultiValue);
        
    }else{
        ABMultiValueAddValueAndLabel(multiValueRef, (__bridge CFStringRef)(contactAddress), kABWorkLabel, NULL);
    }
    
    ABRecordSetValue(recordRef, kABPersonPhoneProperty, multiValueRef, NULL);
    
    //添加记录
    ABAddressBookAddRecord(self.addressBook, recordRef, NULL);
    
    //保存通讯录，提交更改
    ABAddressBookSave(self.addressBook, NULL);
    //释放资源
    CFRelease(recordRef);
    CFRelease(multiValueRef);
}

-(void)deleteAddressbookWithName:(NSString*)name {
    CFStringRef personNameRef=(__bridge CFStringRef)(name);
    CFArrayRef recordsRef= ABAddressBookCopyPeopleWithName(self.addressBook, personNameRef);//根据人员姓名查找
    CFIndex count= CFArrayGetCount(recordsRef);//取得记录数
    for (CFIndex i=0; i!=count; ++i) {
        ABRecordRef recordRef=CFArrayGetValueAtIndex(recordsRef, i);//取得指定的记录
        ABAddressBookRemoveRecord(self.addressBook, recordRef, NULL);//删除
    }
    ABAddressBookSave(self.addressBook, NULL);//删除之后提交更改
    CFRelease(recordsRef);
}

-(BOOL)isValidateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z]+@[A-Za-z0-9]+\\.[A-Za-z]{2,4}";
    
    
    NSRegularExpression *regularexpression = [[NSRegularExpression alloc] initWithPattern:emailRegex options:NSRegularExpressionCaseInsensitive error:nil];//生成正则表达式模板
    //NSUInteger numberofMatch = [regularexpression numberOfMatchesInString:email options:NSMatchingReportProgress range:NSMakeRange(0, email.length)];//计算字符串中匹配正则表达式子字符串的个数
    
    //NSLog(@"%ld",numberofMatch);
    
    NSRange range = [regularexpression rangeOfFirstMatchInString:email options:NSMatchingReportProgress range:NSMakeRange(0, email.length)];//计算第一个匹配正则表达式字符串的位置属性
    
    //NSLog(@"range.location = %lu, range.length = %lu email.length = %lu", range.location, range.length, email.length);
    
    if (range.location == 0
        && range.length == email.length)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

-(NSArray *)getFilenamelistOfType:(NSString *)type fromDirPath:(NSString *)dirPath
{
    NSMutableArray *filenamelist = [NSMutableArray arrayWithCapacity:10];
    NSArray *tmplist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirPath error:nil];
    
    for (NSString *filename in tmplist) {
        NSString *fullpath = [dirPath stringByAppendingPathComponent:filename];
        if ([self isFileExistAtPath:fullpath]) {
            if ([[filename pathExtension] isEqualToString:type]) {
                [filenamelist  addObject:filename];
            }
        }
    }
    
    return filenamelist;
}

-(BOOL)isFileExistAtPath:(NSString*)fileFullPath {
    BOOL isExist = NO;
    isExist = [[NSFileManager defaultManager] fileExistsAtPath:fileFullPath];
    return isExist;
}

-(void)deleteFileWithName:(NSString*)fileName
{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *documentsPath = path;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *iOSPath = [documentsPath stringByAppendingPathComponent:fileName];
    BOOL isSuccess = [fileManager removeItemAtPath:iOSPath error:nil];
    if (isSuccess) {
        NSLog(@"delete success");
    }else{
        NSLog(@"delete fail");
    }
}
@end
