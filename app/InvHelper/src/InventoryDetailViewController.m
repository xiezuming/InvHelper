//
//  InventoryDetailViewController.m
//  Inv Helper
//
//  Created by 谢 祖铭 on 13-7-28.
//  Copyright (c) 2013年 Self. All rights reserved.
//

#import "Constants.h"
#import "InventoryDetailViewController.h"
#import "InventoryEditViewController.h"
#import "InventoryItem.h"
#import "PhotoViewController.h"
#import "PhotoDao.h"

@interface InventoryDetailViewController ()
- (void)configureView;
@end

@implementation InventoryDetailViewController

- (void)setInvertoryItem:(InventoryItem *) newInvertoryItem
{
    if (_invertoryItem != newInvertoryItem) {
        _invertoryItem = newInvertoryItem;
        
        // Update the view.
        //[self configureView];
    }
}

- (void)configureView
{
    if (_invertoryItem) {
        _titleLabel.text = [_invertoryItem title];
        _barCodeLabel.text = [_invertoryItem barcode];
        _statusLabel.text = [_invertoryItem status];
        _quantityLabel.text = [[_invertoryItem quantity] stringValue];
        _categoryLabel.text = [_invertoryItem category];
        _conditionLabel.text = [_invertoryItem condition];
        _priceLabel.text = [[_invertoryItem price] stringValue];
        _sizeLabel.text = [_invertoryItem size];
        _weightLabel.text = [_invertoryItem weight];
        _descriptionLabel.text = [_invertoryItem desc];
        [self setLatitude:_invertoryItem.latitude AndLongitude:_invertoryItem.longitude];
        
        PhotoDao *photoDao = [PhotoDao instance];
        
        _photo1ImageView.userInteractionEnabled = YES;
        _photo1ImageView.image = [photoDao getScaleImageByPhotoName:_invertoryItem.photoname1
                                                        toScaleSize:PHOTO_THUMBNAIL_SIZE];
        _photo2ImageView.userInteractionEnabled = YES;
        _photo2ImageView.image = [photoDao getScaleImageByPhotoName:_invertoryItem.photoname2
                                                        toScaleSize:PHOTO_THUMBNAIL_SIZE];
        _photo3ImageView.userInteractionEnabled = YES;
        _photo3ImageView.image = [photoDao getScaleImageByPhotoName:_invertoryItem.photoname3
                                                        toScaleSize:PHOTO_THUMBNAIL_SIZE];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"ID: %@", [_invertoryItem itemId]];
}

-(void)setLatitude:(NSNumber *)latitude AndLongitude:(NSNumber *)longitude {
    if (latitude && latitude.doubleValue!=0
        && longitude && longitude.doubleValue!=0) {
        // A number formatter for the latitude and longitude.
        static NSNumberFormatter *numberFormatter = nil;
        if (numberFormatter == nil) {
            numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
            [numberFormatter setMaximumFractionDigits:3];
        }
        _locationLabel.text = [NSString stringWithFormat:@"%@, %@",
                               [numberFormatter stringFromNumber:latitude],
                               [numberFormatter stringFromNumber:longitude]];
    } else {
        _locationLabel.text = nil;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureView];
    self.descriptionLabel.lineBreakMode = NSLineBreakByCharWrapping;
    self.descriptionLabel.numberOfLines = 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"editInventoryItem"]) {
        InventoryEditViewController *addItemViewController = [segue destinationViewController];
        addItemViewController.inventoryItem = self.invertoryItem;
    }else if ([[segue identifier] hasPrefix:@"viewPhoto"]) {
        PhotoViewController *photoViewController = [segue destinationViewController];
        int photoIndex = [[[segue identifier] substringFromIndex:9]intValue];
        NSString *photoName = nil;
        switch (photoIndex) {
            case 1:
                photoName = _invertoryItem.photoname1;
                break;
            case 2:
                photoName = _invertoryItem.photoname2;
                break;
            case 3:
                photoName = _invertoryItem.photoname3;
                break;
            default:
                break;
        }
        photoViewController.photoName = photoName;
    }
}

@end
