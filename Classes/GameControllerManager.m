//
//  GameControllerManager.m
//  Nestopia
//
//  Created by Adam Bell on 12/20/2013.
//
//

#import "GameControllerManager.h"
#import <GameController/GameController.h>

#import "Nestopia_Callback.h"

@implementation GameControllerManager {
    GCController *gameController;
}

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        _swapAB = NO;
        
        [self setupController];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(controllerConnected:)
                                                     name:GCControllerDidConnectNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(controllerDisconnected:)
                                                     name:GCControllerDidDisconnectNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:GCControllerDidConnectNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:GCControllerDidDisconnectNotification
                                                  object:nil];
}

+ (instancetype)sharedInstance {
    static dispatch_once_t p = 0;
    
    __strong static id _sharedInstance = nil;
    
    dispatch_once(&p, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

#pragma mark Game Controller Handling

- (void)setupController {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f) {
        NSArray *controllers = [GCController controllers];
        // Grab first controller
        // TODO: Add support for multiple controllers
        gameController = [controllers firstObject];
    }
}

- (BOOL)gameControllerConnected {
    return (gameController != nil);
}

- (void)controllerConnected:(NSNotification *)notification {
    [self setupController];
    [self.delegate gameControllerManagerGamepadDidConnect:self];
}

- (void)controllerDisconnected:(NSNotification *)notification {
    [self setupController];
    [self.delegate gameControllerManagerGamepadDidDisconnect:self];
}


- (int)currentControllerInput {
    int padInput = 0;
    
    if (gameController) {
        if (gameController.extendedGamepad) {
            GCExtendedGamepad *extendedGamepad = gameController.extendedGamepad;
            
            // You should swap A+B because it feels awkward on Gamepad
            if (extendedGamepad.buttonA.pressed) {
                padInput |= (_swapAB ? NCTL_B : NCTL_A);
            }
            if (extendedGamepad.buttonB.pressed) {
                padInput |= (_swapAB ? NCTL_A : NCTL_B);
            }
            
            // This feels super awkward
            /*
             if (extendedGamepad.buttonX.pressed) {
             padInput |= NestopiaPadInputStart;
             }
             if (extendedGamepad.buttonY.pressed) {
             padInput |= NestopiaPadInputSelect;
             }
             */
            
            // Extended Gamepad gets a thumbstick as well
            if (extendedGamepad.dpad.up.pressed || extendedGamepad.leftThumbstick.up.pressed) {
                padInput |= NCTL_UP;
            }
            if (extendedGamepad.dpad.down.pressed || extendedGamepad.leftThumbstick.down.pressed) {
                padInput |= NCTL_DOWN;
            }
            if (extendedGamepad.dpad.left.pressed || extendedGamepad.leftThumbstick.left.pressed) {
                padInput |= NCTL_LEFT;
            }
            if (extendedGamepad.dpad.right.pressed || extendedGamepad.leftThumbstick.right.pressed) {
                padInput |= NCTL_RIGHT;
            }
        }
        
        if (gameController.gamepad) {
            GCGamepad *gamepad = gameController.gamepad;
            
            if (gamepad.buttonA.pressed) {
                padInput |= (_swapAB ? NCTL_B : NCTL_A);
            }
            if (gamepad.buttonB.pressed) {
                padInput |= (_swapAB ? NCTL_A : NCTL_B);
            }
            /*
             if (extendedGamepad.buttonX.pressed) {
             padInput |= NestopiaPadInputStart;
             }
             if (extendedGamepad.buttonY.pressed) {
             padInput |= NestopiaPadInputSelect;
             }
             */
            
            if (gamepad.dpad.up.pressed) {
                padInput |= NCTL_UP;
            }
            if (gamepad.dpad.down.pressed) {
                padInput |= NCTL_DOWN;
            }
            if (gamepad.dpad.left.pressed) {
                padInput |= NCTL_LEFT;
            }
            if (gamepad.dpad.right.pressed) {
                padInput |= NCTL_RIGHT;
            }
        }
    }
    
    return padInput;
}

@end
