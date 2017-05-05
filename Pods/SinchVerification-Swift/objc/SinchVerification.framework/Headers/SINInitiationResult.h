/*
 * Copyright (c) 2016 Sinch AB. All rights reserved.
 *
 * See LICENSE file for license terms and information.
 */

@protocol SINInitiationResult <NSObject>

@property (nonatomic, assign, readonly) BOOL success;
@property (nonatomic, readonly) NSString* contentLanguage;

@end
