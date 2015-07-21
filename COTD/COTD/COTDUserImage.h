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
    
public:
    
    const std::string& getImage() const;
    void setImage(const std::string& image);
    
};

#endif /* defined(__COTD__COTDUserImage__) */
