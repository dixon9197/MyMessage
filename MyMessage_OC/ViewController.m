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

@interface ViewController ()
@property(readwrite)NSMutableArray *contactsArray;
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

//click method
-(IBAction)add:(id)sender
{
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"添加新联系人" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [ac addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.placeholder = @"联系号码/电邮地址";
        textField.keyboardType = UIKeyboardTypeEmailAddress;
    }];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"添加" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        MRProgressOverlayView *overlayer = [MRProgressOverlayView showOverlayAddedTo:self.view animated:YES];
        
        UITextField *tf_contacts = ac.textFields.firstObject;
        
        if ([[tf_contacts text]length]==0) {
            UIAlertController *avc = [UIAlertController alertControllerWithTitle:@"提示" message:@"请输入联系号码/电邮地址." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [avc addAction:action];
            
            [self presentViewController:avc animated:true completion:nil];
            
        }else{
            
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
            
            
            
            NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_contactsArray];
            [u setObject:data forKey:@"contacts"];
            
            [u synchronize];
            
        }
        [overlayer dismiss:YES];
        
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
    
    //BRAOfficeDocumentPackage *spreadsheet = [BRAOfficeDocumentPackage open:[[NSBundle mainBundle]pathForResource:@"haha" ofType:@"xlsx"]];
    
    
    
    //document all file name
    NSArray *filename = [self getFilenamelistOfType:@"xlsx" fromDirPath:path];
    
    if ([filename count]!=0) {
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
                    string = tempStr;
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
                
            }
            
            [self deleteFileWithName:[filename objectAtIndex:i]];
        }
        
        NSUserDefaults *u = [NSUserDefaults standardUserDefaults];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_contactsArray];
        [u setObject:data forKey:@"contacts"];
        
        [u synchronize];
        
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

-(IBAction)selectAll:(id)sender
{
    UIBarButtonItem *btn = sender;
    
    if ([btn.title isEqualToString:@"全选"]) {
        
        [btn setTitle:@"取消全选"];
        for (Contacts *c in _contactsArray) {
            c.isSelect = YES;
        }
        
    }else if ([btn.title isEqualToString:@"取消全选"]) {
        
        [btn setTitle:@"全选"];
        for (Contacts *c in _contactsArray) {
            c.isSelect = NO;
        }
        
    }
    
    [tv reloadData];
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
