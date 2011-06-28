//
//  GamesListViewController.h
//  i4nGoalie
//
//  Created by Maksym Grebenets on 26/03/09.
//  Copyright 2009 i4nApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GamesListViewController : UITableViewController <UIActionSheetDelegate> 
{
	NSInteger selectionRow;
	NSInteger tapSelectionRow;
	NSArray *gamesIdList;
}

@property (nonatomic, retain) NSArray *gamesIdList;

@end

