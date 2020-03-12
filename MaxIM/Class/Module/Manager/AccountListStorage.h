//
//  AccountListStorage.h
//  MaxIM
//
//  Created by 韩雨桐 on 2019/12/17.
//  Copyright © 2019 hyt. All rights reserved.
//

#import "BaseStorage.h"
#import "IMAcount.h"

NS_ASSUME_NONNULL_BEGIN

@interface AccountListStorage : BaseStorage

+ (void)removeAccount:(IMAcount *)account;



@end

NS_ASSUME_NONNULL_END
