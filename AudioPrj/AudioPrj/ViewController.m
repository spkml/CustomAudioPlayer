//
//  ViewController.m
//  AudioPrj
//
//  Created by utsavanand on 12/12/13.
//  Copyright (c) 2013 Utsav Anand. All rights reserved.
//

#import "ViewController.h"
#import "AudioCell.h"
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
    
    allowFrameChange=NO;
    
    aSlider = [[UISlider alloc] init];
    
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
        NSLog(@"Returned height-100");
        return 100;
    }
    else{
        NSLog(@"Returned height-60");
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
    [cell.contentView addSubview:lbl];
    if (indexPath.row==activeRow && allowFrameChange) {
        
    [aSlider setFrame:CGRectMake(10, lbl.frame.size.height+lbl.frame.origin.y+10, 200, 40)];
    [aSlider addTarget:self action:@selector(sliderChanged:)
      forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchUpOutside)];
    [cell.contentView addSubview:aSlider];
        
    }
    return cell;
}

- (void)updateSlider {
    // Update the slider about the music time
    NSLog(@"HEY-%f",audioPlayer.currentTime);
    aSlider.value = audioPlayer.currentTime;
}

- (IBAction)sliderChanged:(UISlider *)sender {
    // Fast skip the music when user scroll the UISlider
    [audioPlayer stop];
    [audioPlayer setCurrentTime:aSlider.value];
    [audioPlayer prepareToPlay];
    [audioPlayer play];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (allowFrameChange && indexPath.row==activeRow) {
        [audioPlayer setCurrentTime:0];
    }
    else if(allowFrameChange && indexPath.row!=activeRow){
    allowFrameChange = YES;
    activeRow = indexPath.row;
[audioTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [audioPlayer setCurrentTime:0];
    [self playAudio];
    }
    else{
        allowFrameChange = YES;
        activeRow = indexPath.row;
        [audioTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self playAudio];
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