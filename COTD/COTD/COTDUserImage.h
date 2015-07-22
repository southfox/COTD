//
//  COTDUserImage.h
//  COTD
//
//  Created by Javier Fuchs on 7/21/15.
//  Copyright (c) 2015 Javier Fuchs. All rights reserved.
//

#ifndef __COTD__COTDUserImage__
#define __COTD__COTDUserImage__

#import <Parse/Parse.h>
#import <PFUser.h>

#include <stdio.h>
#include <string>

#include "COTDImage.h"

class COTDUserImage {
    
protected:
    std::string image;
    std::string searchTerm;
    NSArray *excludeTerms;
    
public:
    
    COTDUserImage();

    const std::string& getImage() const;
    void setImage(const std::string& image);
    
    const std::string& getSearchTerm() const;
    void setSearchTerm(const std::string& searchTerm);
    
    const NSArray* excludeTermsArray() const;
    void addTermToExclude(const NSString *term);
};

#endif /* defined(__COTD__COTDUserImage__) */
