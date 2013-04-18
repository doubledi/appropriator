//
//  ToolboxViewController.m
//  Approp
//
//  Created by Dianna Mertz on 11/2/12.
//  Copyright (c) 2012 Dianna Mertz. All rights reserved.
//

#import "ToolboxViewController.h"

@interface ToolboxViewController ()

@end

@implementation ToolboxViewController


// Method to load the paintings array from the plist
- (void)loadPaintings {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"paintings" ofType:@"plist"];
    self.paintingsArray = [NSMutableArray arrayWithContentsOfFile:path];
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    // Load the data from the plist
    [self loadPaintings];
    [super viewDidLoad];

    self.theNewPaintingView.layer.masksToBounds = YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.paintingsArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Cell
    NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Call the info from the paintings.plist and distribute to cells
    NSDictionary *paintingsInfo = [self.paintingsArray objectAtIndex:indexPath.row];
    
    UIImageView *paintingsImage = (UIImageView *)[cell viewWithTag:100];
    paintingsImage.image = [UIImage imageNamed:[paintingsInfo objectForKey:@"image"]];
    
    UILabel *paintingArtist = (UILabel *)[cell viewWithTag:101];
    paintingArtist.text = [paintingsInfo objectForKey:@"name"];
    
    UILabel *paintingTitle = (UILabel *)[cell viewWithTag:102];
    paintingTitle.text = [paintingsInfo objectForKey:@"title"];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *paintingsInfo = [self.paintingsArray objectAtIndex:indexPath.row];
    
    NSMutableArray *paintingNumber = [[NSMutableArray alloc] init];
        
    UIImageView *newPaintingView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[paintingsInfo objectForKey:@"image_top"]]];
    
    newPaintingView.contentMode = UIViewContentModeScaleAspectFit;

    CGRect frame = newPaintingView.frame;
    frame.size.height = 200;
    frame.size.width = 200;
    newPaintingView.frame = frame;
    newPaintingView.userInteractionEnabled = YES;
    
    [self addGestureRecognizersToView:newPaintingView];

    [paintingNumber addObject:newPaintingView];
    
    [self.theNewPaintingView addSubview:[paintingNumber objectAtIndex:([paintingNumber count]-1)]];
    
    // improves performance
    self.theNewPaintingView.layer.shouldRasterize = YES;
    // adds retina screen support
    self.theNewPaintingView.layer.rasterizationScale = self.view.window.screen.scale;
}

#pragma mark - Gesture Recognizers

// Thanks, Michael Markert!!!

- (void)addGestureRecognizersToView:(UIView*)aView {
    // add pan gesture (to move)
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handlePan:)];
    panGesture.delegate = self;
    [aView addGestureRecognizer:panGesture];
    
    // add pinch gesture (to zoom)
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc]
                                              initWithTarget:self action:@selector(handlePinch:)];
    pinchGesture.delegate = self;
    [aView addGestureRecognizer:pinchGesture];
    
    // add rotation gesture (to rotate)
    UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotation:)];
    rotationGesture.delegate = self;
    [aView addGestureRecognizer:rotationGesture];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPressGesture.delegate = self;
    [aView addGestureRecognizer:longPressGesture];
}

- (void)handlePan:(UIPanGestureRecognizer*)recognizer
{
    
    UIView *theView = recognizer.view;
    if(recognizer.state == UIGestureRecognizerStateBegan ||
       recognizer.state == UIGestureRecognizerStateChanged) {
        
        CGPoint center = theView.center;
        CGPoint translation = [recognizer translationInView:theView.superview];
        
        theView.center = CGPointMake(center.x + translation.x, center.y + translation.y);
        //accumulated offset => reset translation of GestureRecognizer
        [recognizer setTranslation:CGPointZero inView:theView.superview];
    }
}

- (void)handlePinch:(UIPinchGestureRecognizer*)recognizer
{
    UIView *theView = recognizer.view;
    if(recognizer.state == UIGestureRecognizerStateBegan ||
       recognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat scale = recognizer.scale;
        theView.transform = CGAffineTransformScale(theView.transform, scale,
                                                   scale);
        recognizer.scale = 1;   // reset to prevent accumulated offset
    }
}

- (void)handleRotation:(UIRotationGestureRecognizer*)recognizer
{
    UIView *theView = recognizer.view;
    if(recognizer.state == UIGestureRecognizerStateBegan ||
       recognizer.state == UIGestureRecognizerStateChanged) {
        theView.transform = CGAffineTransformRotate(theView.transform,
                                                    recognizer.rotation);
        recognizer.rotation = 0;
    }
}

-(void)handleLongPress:(UILongPressGestureRecognizer*)recognizer
{
    UIView *theView = recognizer.view;
    
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:@"Dianna" action:@selector(customAction:)];
    [menuController setMenuItems:[NSArray arrayWithObject:menuItem]];
    [menuController setTargetRect:CGRectMake(theView.center.x, theView.center.y, 0, 0) inView:self.view];
    [menuController setMenuVisible:YES animated:YES];
    
    
    recognizer.minimumPressDuration = 1.0;
    if(recognizer.state == UIGestureRecognizerStateBegan ||
       recognizer.state == UIGestureRecognizerStateChanged) {
        //[theView removeFromSuperview];
        [theView becomeFirstResponder];
        
    }
}

#pragma UIMenuController required mehtods
-(BOOL)canBecomeFirstResponder {
    return YES;
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    NSLog(@"canPerformAction");
    if (action == @selector(customAction:)) {
        return YES;
    }
    return NO;
}

#pragma Custom Action(s)
-(void)customAction:(id)sender {
    NSLog(@"custom action! %@", sender);
}


@end
