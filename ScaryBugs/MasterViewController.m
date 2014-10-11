//
//  MasterViewController.m
//  ScaryBugs
//
//  Created by Nate Armstrong on 10/6/14.
//  Copyright (c) 2014 Nate Armstrong. All rights reserved.
//

#import <Quartz/Quartz.h>

#import "MasterViewController.h"
#import "ScaryBugDoc.h"
#import "ScaryBugData.h"
#import "EDStarRating.h"
#import "NSImage+Extras.h"

@interface MasterViewController ()

@property (weak) IBOutlet NSTableView *bugsTableView;
@property (weak) IBOutlet NSTextField *bugTitleView;
@property (weak) IBOutlet NSImageView *bugImageView;
@property (weak) IBOutlet EDStarRating *bugRating;
@property (weak) IBOutlet NSView *detailView;
@property (weak) IBOutlet NSButton *deleteButton;

@end

@implementation MasterViewController

- (void)loadView {
  [super loadView];
  self.bugRating.starImage = [NSImage imageNamed:@"shockedface2_empty"];
  self.bugRating.starHighlightedImage = [NSImage imageNamed:@"shockedface2_full"];
  self.bugRating.maxRating = 5.0;
  self.bugRating.delegate = (id<EDStarRatingProtocol>) self;
  self.bugRating.horizontalMargin = 12;
  self.bugRating.editable = YES;
  self.bugRating.displayMode= EDStarRatingDisplayFull;
  self.bugRating.rating = 0.0;

  [self.detailView setHidden:YES];
}

- (ScaryBugDoc *)selectedBugDoc {
  NSInteger selectedRow = [self.bugsTableView selectedRow];
  if (selectedRow >= 0 && self.bugs.count > selectedRow) {
    ScaryBugDoc *doc = [self.bugs objectAtIndex:selectedRow];
    return doc;
  }
  return nil;
}

- (void)setDetailInfo:(ScaryBugDoc *)doc {
  NSString *title = @"";
  NSImage *image = nil;
  float rating = 1.0;
  if (doc != nil) {
    title = doc.data.title;
    image = doc.fullImage;
    rating = doc.data.rating;
  }
  [self.bugTitleView setStringValue:title];
  [self.bugImageView setImage:image];
  [self.bugRating setRating:rating];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
  NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
  if ([tableColumn.identifier isEqualToString:@"BugColumn"]) {
    ScaryBugDoc *bugDoc = [self.bugs objectAtIndex:row];
    cellView.imageView.image = bugDoc.thumbImage;
    cellView.textField.stringValue = bugDoc.data.title;
    return cellView;
  }
  return cellView;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
  return [self.bugs count];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
  ScaryBugDoc *doc = [self selectedBugDoc];
  [self setDetailInfo:doc];
  BOOL selectionIsActive = doc != nil;
  [self.deleteButton setEnabled:selectionIsActive];
  [self.detailView setHidden:!selectionIsActive];
}

- (IBAction)bugTitleDidEndEdit:(id)sender {
  ScaryBugDoc *selectedDoc = [self selectedBugDoc];
  if (selectedDoc) {
    selectedDoc.data.title = [self.bugTitleView stringValue];
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:[self.bugs indexOfObject:selectedDoc]];
    NSIndexSet *columnSet = [NSIndexSet indexSetWithIndex:0];
    [self.bugsTableView reloadDataForRowIndexes:indexSet columnIndexes:columnSet];
  }
}

- (IBAction)addBug:(id)sender {
  ScaryBugDoc *newDoc = [[ScaryBugDoc alloc] initWithTitle:@"New Bug" rating:0.0 thumbImage:nil fullImage:nil];
  [self.bugs addObject:newDoc];
  NSInteger newRowIndex = self.bugs.count-1;
  [self.bugsTableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:newRowIndex]
                            withAnimation:NSTableViewAnimationEffectGap];
  [self.bugsTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:newRowIndex]
                  byExtendingSelection:NO];
  [self.bugsTableView scrollRowToVisible:newRowIndex];
}

- (IBAction)deleteBug:(id)sender {
  ScaryBugDoc *selectedDoc = [self selectedBugDoc];
  if (selectedDoc) {
    [self.bugs removeObject:selectedDoc];
    [self.bugsTableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:self.bugsTableView.selectedRow]
                              withAnimation:NSTableViewAnimationSlideRight];
    [self setDetailInfo:nil];
  }
}

- (void)starsSelectionChanged:(EDStarRating *)control rating:(float)rating {
  ScaryBugDoc *selectedDoc = [self selectedBugDoc];
  if (selectedDoc) {
    selectedDoc.data.rating = self.bugRating.rating;
  }
}

- (IBAction)changePicture:(id)sender {
  ScaryBugDoc *selectedDoc = [self selectedBugDoc];
  if (selectedDoc) {
    [[IKPictureTaker pictureTaker] beginPictureTakerSheetForWindow:self.view.window
                                                      withDelegate:self
                                                      didEndSelector:@selector(pictureTakerDidEnd:returnCode:contextInfo:)
                                                         contextInfo:nil];
  }
}

- (void)pictureTakerDidEnd:(IKPictureTaker *)picker
                 returnCode:(NSInteger)code
                contextInfo:(void *)contextInfo {
  NSImage *image = [picker outputImage];
  if (image !=nil && code == NSOKButton) {
    [self.bugImageView setImage:image];
    ScaryBugDoc *selectedBugDoc = [self selectedBugDoc];
    if (selectedBugDoc) {
      selectedBugDoc.fullImage = image;
      selectedBugDoc.thumbImage = [image imageByScalingAndCroppingForSize:CGSizeMake(44, 44)];
      NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:[self.bugs indexOfObject:selectedBugDoc]];
      NSIndexSet *columnSet = [NSIndexSet indexSetWithIndex:0];
      [self.bugsTableView reloadDataForRowIndexes:indexSet columnIndexes:columnSet];
    }
  }
}

@end