//
//  COTDImage.h
//  COTD
//
//  Created by Javier Fuchs on 7/21/15.
//  Copyright (c) 2015 Javier Fuchs. All rights reserved.
//

#ifndef __COTD__COTDImage__
#define __COTD__COTDImage__

#include <stdio.h>
#include <string>

class COTDImage {
private:
    std::string objectId;
    std::string fullUrl;
    int likes;
    
public:
    
    const std::string& getObjectId() const;
    void setObjectId(const std::string& objectId);

    const std::string& getFullUrl() const;
    void setFullUrl(const std::string& fullUrl);

    const int getLikes() const;
    void setLikes(const int likes);
    
};
#endif /* defined(__COTD__COTDImage__) */
