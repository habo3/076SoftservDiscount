//
//  KxIntroViewController.m
//  kxintro project
//  https://github.com/kolyvan/kxintro/
//
//  Created by Kolyvan on 11.04.13.
//

/*
 Copyright (c) 2013 Konstantin Bukreev. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 - Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 - Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


#import "KxIntroViewController.h"
#import "KxIntroView.h"
#import "KxIntroViewPage.h"

@interface KxIntroViewController () <KxIntroViewDelegate>
@property (readwrite, nonatomic, strong) KxIntroView *introView;
@end

@implementation KxIntroViewController {
    
    NSArray *_pages;
    BOOL    _needRestoreStatusBar;
}

- (KxIntroView *) introView
{
    if (!_introView) {
        
        _introView = [[KxIntroView alloc] initWithPages:_pages];
        _introView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _introView.delegate = self;
    }
    return _introView;
}

- (id)initWithPages: (NSArray *) pages
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _pages = pages;
    }
    return self;
}

- (void) loadView
{
    self.view = self.introView;
}

- (void) presentInView: (UIView *) view
{
    self.view.frame = view.bounds;
    [view addSubview:self.view];
}

- (void) presentInViewController: (UIViewController *) viewController
                fullScreenLayout: (BOOL) fullScreenLayout
{
    if (fullScreenLayout) {
        
        self.wantsFullScreenLayout = YES;
        UIApplication *app = [UIApplication sharedApplication];
        if (!app.statusBarHidden) {
            _needRestoreStatusBar = YES;
            [app setStatusBarHidden:YES withAnimation:NO];
        }
    }
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [viewController presentViewController:self animated:NO completion:nil];
}

#pragma mark - KxIntroViewDelegate

- (void)introView:(KxIntroView *)view didComplete:(BOOL)finished
{
    if (self.presentingViewController) {
        
        [self dismissViewControllerAnimated:!finished completion:NO];
        
    } else if (self.view.superview) {
        
        if (!finished) {
            
            [UIView animateWithDuration:0.2
                             animations:^
             {
                 self.view.alpha = 0;
             }
                             completion:^(BOOL finished)
             {
                 [self.view removeFromSuperview];
             }];
            
        } else {
            
            [self.view removeFromSuperview];
        }
    }
    
    if (_needRestoreStatusBar) {
        UIApplication *app = [UIApplication sharedApplication];
        [app setStatusBarHidden:NO withAnimation:YES];
    }
}

+(void) performIntro:(UIViewController *) sender
{
    KxIntroViewPage *page0 = [KxIntroViewPage introViewPageWithTitle: @"Швидке навчання"
                                                          withDetail: @"Це швидке навчання користування програмую, якщо ви бажаєте пропустити його - нажміть вiдповідну кнопку. Для переходу до наступного кроку зробіть скрол вліво."
                                                           withImage: [UIImage imageNamed:@"IntrolImage.png"]];
    
    KxIntroViewPage *page1 = [KxIntroViewPage introViewPageWithTitle: @"Карта"
                                                          withDetail: @"На карті можна побачити всі заклади, які вснесені в базу. При кліці на заклад появиться коротка інформація про нього та, якщо ввімкнена Геолокація, прокладеться маршрут від вашого поточного місця знаходження до даного закладу. На навігаційній панелі ви можете найти кнопку Назад та кнопку Філтрації. Також, при ввімкненій Геолокації, знизу відображається кнопка переходу до вашого місця знаходження "
                                                           withImage: [UIImage imageNamed:@"IntroImageMap.jpg"]];
    
    KxIntroViewPage *page2 = [KxIntroViewPage introViewPageWithTitle: @"Список"
                                                          withDetail: @"Тут находяться всі заклади, де надаються знижки, в альтернативному вигляді. Є можливість пошуку та фільтрації."
                                                           withImage: [UIImage imageNamed:@"IntroImageList.jpg"]];
    
    KxIntroViewPage *page3 = [KxIntroViewPage introViewPageWithTitle: @"Деталі"
                                                          withDetail: @"Це вікно призначене для показу детальної інформації про даний заклад, а саме: категорія закладу, логотип, контактна інформація. Також є можливість добавляти до обраного, поскаржитися, поділитися з друзями інформацією про заклад. Також при кліці по телефону, електроній пошті, сайту відбудеться відповідна дія."
                                                           withImage: [UIImage imageNamed:@"IntroImageDetails.jpg" ]];
    
    KxIntroViewController *vc = [[KxIntroViewController alloc ] initWithPages:@[ page0, page1, page2, page3]];
    vc.introView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"IntroBackground.png"]];;
    vc.introView.animatePageChanges = YES;
    vc.introView.gradientBackground = NO;
    [vc presentInViewController:sender fullScreenLayout:YES];
}
@end
