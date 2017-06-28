//
//  OJColor.h
//  OJNotificationDemo
//
//  Created by Juwencheng on 28/06/2017.
//  Copyright © 2017 Owen Ju. All rights reserved.
//

#ifndef OJColor_h
#define OJColor_h

#define HEXCOLOR(hex, a)  \
[UIColor colorWithRed:(float)((hex&0xFF0000)>>16)/255.0 green:(float)((hex&0xFF00)>>8)/255.0 blue:(float)((hex&0xFF))/255.0 alpha:1]
#define HEXCOLORWITALPHA(hex, a) \
[UIColor colorWithRed:(float)((hex&0xFF0000)>>16)/255.0 green:(float)((hex&0xFF00)>>8)/255.0 blue:(float)((hex&0xFF))/255.0 alpha:a]

#endif /* OJColor_h */
