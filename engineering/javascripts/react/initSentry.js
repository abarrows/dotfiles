import * as Sentry from '@sentry/node';

// based on https://github.com/vercel/next.js/tree/f1f529096a8062b525dd5af1d8e533ce9a6f3ddc/examples/with-sentry-simple
const initSentry = () => {
  if (process.env.NEXT_PUBLIC_SENTRY_DSN) {
    Sentry.init({
      enabled: process.env.NODE_ENV === 'production',
      dsn: process.env.NEXT_PUBLIC_SENTRY_DSN,
      environment: process.env.NEXT_PUBLIC_DEPLOY_ENV,
      release: `${process.env.NEXT_PUBLIC_APP_VERSION}`,
      // https://docs.sentry.io/platforms/javascript/configuration/filtering/#decluttering-sentry
      ignoreErrors: [
        // Random plugins/extensions
        'top.GLOBALS',
        // See: http://blog.errorception.com/2012/03/tale-of-unfindable-js-error.html
        'originalCreateNotification',
        'canvas.contentDocument',
        'MyApp_RemoveAllHighlights',
        'http://tt.epicplay.com',
        "Can't find variable: ZiteReader",
        'jigsaw is not defined',
        'ComboSearch is not defined',
        'http://loading.retry.widdit.com/',
        'atomicFindClose',
        // Facebook borked
        'fb_xd_fragment',
        // ISP "optimizing" proxy - `Cache-Control: no-transform` seems to
        // reduce this. (thanks @acdha)
        // See http://stackoverflow.com/questions/4113268
        'bmi_SafeAddOnload',
        'EBCallBackMessageReceived',
        // See http://toolbar.conduit.com/Developer/HtmlAndGadget/Methods/JSInjection.aspx
        'conduitPage',
      ],
      denyUrls: [
        // Facebook flakiness
        /graph\.facebook\.com/i,
        // Facebook blocked
        /connect\.facebook\.net\/en_US\/all\.js/i,
        // Woopra flakiness
        /eatdifferent\.com\.woopra-ns\.com/i,
        /static\.woopra\.com\/js\/woopra\.js/i,
        // Chrome extensions
        /extensions\//i,
        /^chrome:\/\//i,
        // Other plugins
        /127\.0\.0\.1:4001\/isrunning/i, // Cacaoweb
        /webappstoolbarba\.texthelp\.com\//i,
        /metrics\.itunes\.apple\.com\.edgesuite\.net\//i,
        // Filter common ad/marketing URLs
        /doubleclick\.net\//i,
        /amazon-adsystem\.com\//i,
        /pubmatic\.com\//i,
        /exelator\.com\//i,
        /casalmedia\.com\//i,
        /rubiconproject\.com\//i,
        /openx\.net\//i,
        /adnxs\.com\//i,
        /rxthdr\.com/i,
        /kxcdn\.com/i,
        /padsquad\.com/i,
        /flashtalking\.com/i,
        /yandex\.ru/i,
        /ads\/richmedia/i,
        /prebid/i,
        /ampproject/i,
      ],
    });
  }
};

export default initSentry;
