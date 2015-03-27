//
//  ViewController.m
//  ClDropIntegration
//
//  Created by Abbie on 3/27/15.
//  Copyright (c) 2015 Abbie. All rights reserved.
//

#import "ViewController.h"
#import <DropboxSDK/DropboxSDK.h>

@interface ViewController ()<DBRestClientDelegate>
@property (nonatomic,strong)UIButton *loginButton;
@property (nonatomic,strong)UIButton *uploadButton;
@property (nonatomic,strong)DBRestClient *uploadClient;
@property (nonatomic,strong)UIButton *listButton;
@property (nonatomic,strong)UIButton *downloadButton;
@property (nonatomic,strong)NSString *localPath;
@property (nonatomic,strong)NSString *desktopPath;
@property (nonatomic,strong)UIButton *createButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    DBSession *session = [[DBSession alloc]initWithAppKey:@"qsbjmgblgs01oxo" appSecret:@"zx5h24u9mcr9jw4" root:kDBRootDropbox];
    [DBSession setSharedSession:session];
    self.loginButton = [[UIButton alloc]init];
    [self.loginButton setTitle:@"Dropbox Login" forState:UIControlStateNormal];
    self.loginButton.frame = CGRectMake(100, 100, 200, 80);
    [self.loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.loginButton addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
    self.loginButton.backgroundColor = [UIColor blueColor];
    [self.view addSubview:self.loginButton];
    
    self.uploadButton = [[UIButton alloc]init];
    [self.uploadButton setTitle:@"Upload File" forState:UIControlStateNormal];
    self.uploadButton.frame = CGRectMake(100, 200, 200, 80);
    [self.uploadButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.uploadButton addTarget:self action:@selector(uploadAction) forControlEvents:UIControlEventTouchUpInside];
    self.uploadButton.backgroundColor = [UIColor blueColor];
    [self.view addSubview:self.uploadButton];
    
    self.listButton = [[UIButton alloc]init];
    [self.listButton setTitle:@"List File" forState:UIControlStateNormal];
    self.listButton.frame = CGRectMake(100, 300, 200, 80);
    [self.listButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.listButton addTarget:self action:@selector(listAction) forControlEvents:UIControlEventTouchUpInside];
    self.listButton.backgroundColor = [UIColor blueColor];
    [self.view addSubview:self.listButton];
    
    self.downloadButton = [[UIButton alloc]init];
    [self.downloadButton setTitle:@"Download File" forState:UIControlStateNormal];
    self.downloadButton.frame = CGRectMake(100, 400, 200, 80);
    [self.downloadButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.downloadButton addTarget:self action:@selector(downloadAction) forControlEvents:UIControlEventTouchUpInside];
    self.downloadButton.backgroundColor = [UIColor blueColor];
    [self.view addSubview:self.downloadButton];
    
    self.createButton = [[UIButton alloc]init];
    [self.createButton setTitle:@"Create Folder" forState:UIControlStateNormal];
    self.createButton.frame = CGRectMake(100, 500, 200, 80);
    [self.createButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.createButton addTarget:self action:@selector(createAction) forControlEvents:UIControlEventTouchUpInside];
    self.createButton.backgroundColor = [UIColor blueColor];
    [self.view addSubview:self.createButton];
    
    self.desktopPath = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES)[0];
    NSString *text = @"Heyyy it is my second upload";
    NSString *filename = @"ghi.txt";
    NSString *localDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *localPath = [localDir stringByAppendingPathComponent:filename];
    self.uploadClient = [[DBRestClient alloc]initWithSession:[DBSession sharedSession]];
    self.uploadClient.delegate = self;

    
}

#pragma mark - DropBox Login

-(void)loginAction
{
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession]linkFromController:self];
    }
    else
    {
        [[DBSession sharedSession]linkFromController:self];
    }
}
#pragma mark - uploading files

-(void)uploadAction
{
    //self.uploadClient = [[DBRestClient alloc]initWithSession:[DBSession sharedSession]];
   // self.uploadClient.delegate = self;
    NSString *text = @"Heyyy it is my second upload";
    NSString *filename = @"ghi.txt";
    NSString *localDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    self.localPath = [localDir stringByAppendingPathComponent:filename];
    NSLog(@"Local Path %@",self.localPath);
   
    [text writeToFile:self.localPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    // Upload file to Dropbox
    NSString *destDir = @"/ThirdFolder";
    [self.uploadClient uploadFile:filename toPath:destDir withParentRev:nil fromPath:self.localPath];
}

#pragma mark - Uploading delegates

- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath
              from:(NSString *)srcPath metadata:(DBMetadata *)metadata {
    NSLog(@"File uploaded successfully to path: %@", metadata.path);
}

- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error {
    NSLog(@"File upload failed with error: %@", error);
}

#pragma mark - Listing Files

-(void)listAction
{
[self.uploadClient loadMetadata:@"/"];
    
}

#pragma mark - Listing Delegates

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    if (metadata.isDirectory) {
        NSLog(@"Folder '%@' contains:", metadata.path);
        for (DBMetadata *file in metadata.contents) {
            NSLog(@"	%@", file.filename);
        }
    }
}

- (void)restClient:(DBRestClient *)client
loadMetadataFailedWithError:(NSError *)error {
    NSLog(@"Error loading metadata: %@", error);
}

#pragma mark - Downloading

-(void)downloadAction

{
    [self.uploadClient loadFile:@"/my/ghi.txt" intoPath:self.desktopPath];
    
}

- (void)restClient:(DBRestClient *)client loadedFile:(NSString *)localPath
       contentType:(NSString *)contentType metadata:(DBMetadata *)metadata {
    NSLog(@"File loaded into path: %@", localPath);
}

- (void)restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error {
    NSLog(@"There was an error loading the file: %@", error);
}

#pragma mark - Creating New Folder

-(void)createAction
{
    [self.uploadClient createFolder:@"/ThirdFolder"];
    
}

// Folder is the metadata for the newly created folder
- (void)restClient:(DBRestClient*)client createdFolder:(DBMetadata*)folder{
    NSLog(@"Created Folder Path %@",folder.path);
    NSLog(@"Created Folder name %@",folder.filename);
}
// [error userInfo] contains the root and path
- (void)restClient:(DBRestClient*)client createFolderFailedWithError:(NSError*)error{
    NSLog(@"%@",error);
}
@end
