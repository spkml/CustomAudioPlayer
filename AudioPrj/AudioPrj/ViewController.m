//
//  ViewController.m
//  AudioPrj
//
//  Created by utsavanand on 12/12/13.
//  Copyright (c) 2013 Utsav Anand. All rights reserved.
//

#import "ViewController.h"
#import "AudioCell.h"
#import "NameViewController.h"
#import "DateViewController.h"

@interface ViewController ()

@end

@implementation ViewController
{
    NSMutableArray *tableData;
}
@synthesize audioTable;
@synthesize activeRow;
@synthesize allowFrameChange;
@synthesize aSlider;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    allowFrameChange=NO;
    
    aSlider = [[UISlider alloc] init];
    
    [self renderNavigationBar];
    
    // Initialising the tableView
    
    audioTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [audioTable setDelegate:self];
    [audioTable setDataSource:self];
    [self.view addSubview:audioTable];
    
    // Initialising table with dummy data
    
    tableData = [NSMutableArray arrayWithObjects:@"Audio Demo 1",@"Audio Demo 2",@"Audio Demo 1",@"Audio Demo 2",@"Audio Demo 1",@"Audio Demo 2",@"Audio Demo 1",@"Audio Demo 2",@"Audio Demo 1",@"Audio Demo 2",@"Audio Demo 1",@"Audio Demo 2", nil];
    
    // Audio Player test
    
    NSString* resourcePath = @"http://www.interactalbums.com/app/albums/892/302/targets/ipad/media/1/1003.mp3"; //your url
    NSData *_objectData = [NSData dataWithContentsOfURL:[NSURL URLWithString:resourcePath]];
    NSError *error;
    
    audioPlayer = [[AVAudioPlayer alloc] initWithData:_objectData error:&error];
    audioPlayer.numberOfLoops = 0;
    audioPlayer.volume = 1.0f;
    [audioPlayer prepareToPlay];
    aSlider.maximumValue = [audioPlayer duration];
}

-(void)renderNavigationBar{
    UIButton *nameFilterBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 64, 24)];
    [nameFilterBtn setTitle:@"Name" forState:UIControlStateNormal];
    [nameFilterBtn addTarget:self action:@selector(filterByName:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *nameFilter = [[UIBarButtonItem alloc] initWithCustomView:nameFilterBtn];
    self.navigationItem.leftBarButtonItem = nameFilter;
    
    UIButton *dateFilterBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 64, 24)];
    [dateFilterBtn setTitle:@"Date" forState:UIControlStateNormal];
    [dateFilterBtn addTarget:self action:@selector(filterByDate:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *dateFilter = [[UIBarButtonItem alloc] initWithCustomView:dateFilterBtn];
    self.navigationItem.rightBarButtonItem = dateFilter;
    self.navigationItem.title = @"Connect & Sell";
    NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if ([[ver objectAtIndex:0] intValue] >= 7) {
        self.navigationController.navigationBar.barTintColor = [UIColor grayColor];
        self.navigationController.navigationBar.translucent = NO;
    } else {
        self.navigationController.navigationBar.tintColor = [UIColor grayColor];

    }
    
}

-(void)filterByName:(id)sender{
    NameViewController *nameVC = [[NameViewController  alloc] init];
    
    [self.navigationController pushViewController:nameVC animated:YES];
}

-(void)filterByDate:(id)sender{
    DateViewController *dateVC = [[DateViewController  alloc] init];
    
    [self.navigationController pushViewController:dateVC animated:YES];
}

-(void)playAudio
{
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(updateSlider)
                                   userInfo:nil
                                    repeats:YES];
    [audioPlayer play];
}
-(void)stopAudio
{
    [audioPlayer stop];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [tableData count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
  
    if (indexPath.row==activeRow && allowFrameChange) {
        return 100;
    }
    else{
        return 60;
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *tableCellIdentifier = @"AudioCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableCellIdentifier];
    }

    for(UIView *subview in cell.contentView.subviews)
    {
        if([subview isKindOfClass: [UIButton class]] || [subview isKindOfClass: [UILabel class]] || [subview isKindOfClass: [UISlider class]] )
        {
            [subview removeFromSuperview];
        }
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

    // To adjust the imcomplete separator in iOS7 tableview
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 200, 40)];
    lbl.text=[tableData objectAtIndex:indexPath.row];
    lbl.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:lbl];
    
    if (indexPath.row==activeRow && allowFrameChange){
    
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.tag=indexPath.section;
        if (audioPlayer.playing) {
            [button setTitle:@"Pause" forState:UIControlStateNormal];
        }
        else{
        [button setTitle:@"Play" forState:UIControlStateNormal];
        }
        [button addTarget:self
                   action:@selector(audioShuffle:)
         forControlEvents:UIControlEventTouchDown];
        button.frame = CGRectMake(10, lbl.frame.size.height+lbl.frame.origin.y, 60, 40);
        [cell.contentView addSubview:button];
        
    [aSlider setFrame:CGRectMake(80, lbl.frame.size.height+lbl.frame.origin.y, 200, 40)];
    [aSlider addTarget:self action:@selector(sliderChanged:)
      forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchUpOutside)];
    aSlider.backgroundColor = [UIColor clearColor];
    [cell.contentView addSubview:aSlider];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView
 willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"TESTTEST-%@",indexPath);
    if (indexPath.row==activeRow && allowFrameChange) {
        [cell setBackgroundColor:[UIColor whiteColor]];
    }
    else{
        [cell setBackgroundColor:[UIColor lightGrayColor]];
    }
}

- (void)updateSlider {
    // Update the slider about the music time
    aSlider.value = audioPlayer.currentTime;
}

- (IBAction)sliderChanged:(UISlider *)sender {
    // Fast skip the music when user scroll the UISlider
    [audioPlayer stop];
    [audioPlayer setCurrentTime:aSlider.value];
    [audioPlayer prepareToPlay];
    [audioPlayer play];
}

-(void)audioShuffle:(id)sender{
    UIButton *btn = (UIButton *)sender;
    if([btn.currentTitle isEqualToString:@"Play"]){
        NSLog(@"heyheyey");
        [self playAudio];
         [audioTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:activeRow inSection:btn.tag]] withRowAnimation:UITableViewRowAnimationNone];
        
    }
    else if([btn.currentTitle isEqualToString:@"Pause"]){
        [self stopAudio];
        [audioTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:activeRow inSection:btn.tag]] withRowAnimation:UITableViewRowAnimationNone];
    }
    else{
        NSLog(@"hellohello");
    }

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (allowFrameChange && indexPath.row==activeRow) {
        [audioPlayer setCurrentTime:0];
//        [self stopAudio];
        allowFrameChange=NO;
        [audioTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if(allowFrameChange && indexPath.row!=activeRow){
    allowFrameChange = NO;
        
    // Currently reverted to reloadData method since, if we update an individual cell we have to keep track of the previous active cell as well and then update that which requires the previous cell's indexpath and currently we have only row
        [self stopAudio];
        NSInteger deactivatedRow = activeRow;
        activeRow = indexPath.row;
     [audioTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:deactivatedRow inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
//        [audioTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [audioPlayer setCurrentTime:0];
//    [self playAudio];
    }
    else{
        allowFrameChange = YES;
        NSInteger deactivatedRow = activeRow;
        activeRow = indexPath.row;
        [audioTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:deactivatedRow inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationFade];
        allowFrameChange = YES;
//        [self playAudio];
        [audioTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

// Audio Player delegate methods

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"FINISHED PLAYING");
}
-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    NSLog(@"ERROR IN PLAYER");
}
-(void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    NSLog(@"AUDIO PLAYER BEGIN INTERRUPTION");
}
-(void)audioPlayerEndInterruption:(AVAudioPlayer *)player
{
    NSLog(@"AUDIO PLAYER END INTERRUPTION");

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
