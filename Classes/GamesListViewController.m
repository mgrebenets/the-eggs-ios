//
//  CountriesViewController.m
//  i4nGoalie
//
//  Created by Maksym Grebenets on 26/03/09.
//  Copyright 2009 i4nApps. All rights reserved.
//

#import "GamesListViewController.h"
#import "The_EggsAppDelegate.h"

@implementation GamesListViewController

@synthesize gamesIdList;

#pragma mark dealloc
- (void)dealloc {
	[gamesIdList release];
    [super dealloc];
}

- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
		self.title = NSLocalizedString(@"Skins", @"Skins");

		// is set when loading data
		selectionRow = -1;
		
		i4nGoalieAppDelegate *delegate = (i4nGoalieAppDelegate *)[[UIApplication sharedApplication] delegate];
		self.gamesIdList = delegate.gamesIdList;
		
		selectionRow = [gamesIdList indexOfObject:[NSNumber numberWithInteger:delegate.currentGameId]];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:NO animated:animated];
	[self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
	// resize the table view here to add space for navigation bar
	// we just now that navigation bar is 32 pixels in height
	// though it would be nice to do the whole stuff right
	self.tableView.frame = CGRectMake(0, 32, 480, 320 - 32);
	
	if (selectionRow >= 0) {
		NSIndexPath *selIndexPath = [NSIndexPath indexPathForRow:selectionRow inSection:0];
		[self.tableView scrollToRowAtIndexPath:selIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:animated];
	}
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

#pragma mark UITableViewDataSource implementation
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [gamesIdList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *cellId = @"gamesListCell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellId] autorelease];
	}
	
	// Configure the cell
	i4nGoalieAppDelegate *delegate = (i4nGoalieAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSString *gamePrefix = [delegate gamePrefixForId:[[gamesIdList objectAtIndex:indexPath.row] integerValue]];
	NSString *imageName = [gamePrefix stringByAppendingString:@"-app-icon.png"];
	cell.imageView.image = [UIImage imageNamed:imageName];
	cell.textLabel.text = NSLocalizedString(gamePrefix, gamePrefix);
	cell.textLabel.textColor = [UIColor blackColor];
	
	if (indexPath.row == selectionRow) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
	// mark used skin with red
	if ([[gamesIdList objectAtIndex:indexPath.row] integerValue] == delegate.oldGameId) {
		cell.textLabel.textColor = [UIColor redColor];
	}
	
	return cell;
}

#pragma mark UITableViewDelegate implementation
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60.0;
}

- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row == selectionRow) {
		return UITableViewCellAccessoryCheckmark;
	}
	return UITableViewCellAccessoryNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];    // YES?
	if (indexPath.row == selectionRow) {
		// same row selected
		return;
	}
	
	// update selection index and value
	tapSelectionRow = indexPath.row;
	
	// display an action sheet with "need restart" warning
	// proceed to changing current game id in the action sheet delegate method
	// show action sheet with request
	i4nGoalieAppDelegate *delegate = (i4nGoalieAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSString *actionTitle = nil;
	if (delegate.oldGameId == [[gamesIdList objectAtIndex:tapSelectionRow] integerValue]) {
            actionTitle = NSLocalizedString(@"Current Skin Title", @"Current Skin Title");
	} else {
            actionTitle = NSLocalizedString(@"Skin Change Title", @"Skin Change Title");
	}
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:actionTitle
															 delegate:self 
													cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
											   destructiveButtonTitle:NSLocalizedString(@"OK", @"OK")
													otherButtonTitles:nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
	[actionSheet showInView:self.view];
	[actionSheet release];	
}

#pragma mark UIActionSheetDelegate protocol implementation
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// 0 index is for OK button
	if (buttonIndex != 0) return;
	
	// unckeck old cell
	if (selectionRow >= 0) {
		NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:selectionRow inSection:0];
		UITableViewCell *oldCell = [self.tableView cellForRowAtIndexPath:oldIndexPath];
		oldCell.accessoryType = UITableViewCellAccessoryNone;
	}
	
	// update selection row with previously saved tap selection row
	selectionRow = tapSelectionRow;
	NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:selectionRow inSection:0];
	
	// check new cell
	UITableViewCell *newCell = [self.tableView cellForRowAtIndexPath:newIndexPath];
	newCell.accessoryType = UITableViewCellAccessoryCheckmark;
	
	// Update new game selection to the app deletate (the setter will be called)
	((i4nGoalieAppDelegate *)[[UIApplication sharedApplication] delegate]).currentGameId = [[gamesIdList objectAtIndex:selectionRow] integerValue];
	
	[self viewWillAppear:NO];  // NEED IT?
	// or better refresh the table data
}


@end
