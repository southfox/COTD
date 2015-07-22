//
//  COTDUserImage.m
//  COTD
//
//  Created by Javier Fuchs on 7/21/15.
//  Copyright (c) 2015 Javier Fuchs. All rights reserved.
//

#import "COTDUserImage.h"

COTDUserImage::COTDUserImage()
{
    this->excludeTerms = [NSMutableArray array];
}

const std::string &COTDUserImage::getImage() const
{
    return this->image;
}

void COTDUserImage::setImage(const std::string &image)
{
    this->image = image;
}

const std::string& COTDUserImage::getSearchTerm() const
{
    return this->searchTerm;
}

void COTDUserImage::setSearchTerm(const std::string& searchTerm)
{
    this->searchTerm = searchTerm;
}

const NSArray* COTDUserImage::excludeTermsArray() const
{
    return this->excludeTerms;
}

void COTDUserImage::addTermToExclude(const NSString *term)
{
    [this->excludeTerms performSelector:@selector(addObject:) withObject:term];
}





