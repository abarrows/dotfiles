/*
 * Updated: 2020 amuCommon.js
 * 2011 Pyntail, LLC
 * 5777 W. Century Blvd. Suite 1250 Los Angeles,
 * CA 90045 / info@pyntail.com / (310) 692 4348
 */
// global variables
var period = 1000; // default time duration for counting seconds 1000msec = 1sec

var online = navigator.onLine; // Are we connected to a network
var timer = $.timer(countSecond, period);
var hbase;
var e = 'd';
var runTimer = true;
var counter = 0;
var start = false; // whether timer is started, starts on first tap on any input box

var regular = true; // game mode regular or advanced

var isRetina = false;
var cur_puz_time = null;
var root = document.querySelector('html');
window.gameCommon = {
  loadErrorCount: 0,
  isiOS: false,
  isIE: false,
  isOpera: false,
  isSafari: false,
  isAndroid: false,
  isChrome: false,
  isFirefox: false,
  subscriptionUrl: document
    .querySelector('html')
    .getAttribute('data-subscription-url'),
  subscriptionUrlDaily: document
    .querySelector('html')
    .getAttribute('data-subscription-url-daily'),
  subscriptionUrlSunday: document
    .querySelector('html')
    .getAttribute('data-subscription-url-sunday'),
  clientCode: document.querySelector('html').getAttribute('data-client-code'),
  gameCode: document.querySelector('html').getAttribute('data-game-code'),
  gameLanguage: document
    .querySelector('html')
    .getAttribute('data-game-language'),
  gameDate: document.querySelector('html').getAttribute('data-game-date'),
  gameAssetsBasePath: document
    .querySelector('html')
    .getAttribute('data-game-assets-base-path'),
  gameAssetsAudioPath: document
    .querySelector('html')
    .getAttribute('data-game-assets-audio-path'),
  gameAssetsImagePath: document
    .querySelector('html')
    .getAttribute('data-game-assets-image-path'),
  gameAssetsStylesheetsPrintPath: document
    .querySelector('html')
    .getAttribute('data-game-assets-stylesheets-print-path'),
  gameAssetsScriptsPath: document
    .querySelector('html')
    .getAttribute('data-game-assets-scripts-path'),
  gameAssetsFontsPath: document
    .querySelector('html')
    .getAttribute('data-game-assets-fonts-path'),
  gameMilestone: function(milestone, milestoneValue = undefined) {
    if (
      typeof milestone === undefined ||
      window.gameCommon.gameCode !== 'iwin'
    ) {
      return;
    }
    if (milestone === 'init') {
      console.log(`gameMilestone: The milestone hit was ${milestone}`);
      return iConsole.game.loadProgress({
        progress: 1
      });
    }
    if (milestone === 'loaded') {
      console.log(`gameMilestone: The milestone hit was ${milestone}`);
      return iConsole.game.loaded({
        success: true
      });
    }
    if (milestone === 'ready') {
      console.log(`gameMilestone: The milestone hit was ${milestone}`);
      return iConsole.game.ready({});
    }
    if (milestone == 'leaderboard') {
      if (typeof milestoneValue === undefined) {
        return;
      }
      iConsole.game.postHighScore({
        score: milestoneValue
      });
      console.log(
        `gameCommon.gameMilestone: The milestone is: ${milestone} and the score is: ${milestoneValue}`
      );
    } else if (milestone == 'storage') {
      if (typeof milestoneValue === undefined) {
        return;
      }
      console.log(
        `gameCommon.gameMilestone: The milestone is: ${milestone} and the storage location is: ${milestoneValue}`
      );
      return iConsole.game.setGameData({
        data: milestoneValue
      });
    } else {
      console.log(`gameCommon.gameMilestone: The milestone is: ${milestone}`);
    }

    return milestone;
  },
  contentUrl: function(date) {
    var dateString;
    if (typeof date === 'string') dateString = date;
    else dateString = window.gameCommon.elementsForDate(date).join('-');
    var url =
      window.gameCommon.subscriptionUrl + '/d/' + dateString + '/data.json';
    return url;
  },
  detectBrowser: function detectBrowser() {
    window.gameCommon.isiOS = /iPhone|iPad|iPod/i.test(navigator.userAgent);
    window.gameCommon.isIE = false || testCSS('msTransform'); // At least IE6

    window.gameCommon.isOpera = !!(window.opera && window.opera.version); // Opera 8.0+

    window.gameCommon.isSafari =
      Object.prototype.toString
        .call(window.HTMLElement)
        .indexOf('Constructor') > 0;
    window.gameCommon.isAndroid = /Android/i.test(navigator.userAgent);
    window.gameCommon.isChrome = /Chrome/i.test(navigator.userAgent);
    window.gameCommon.isFirefox = /Firefox/i.test(navigator.userAgent);
  },
  detectDimensions: function detectDimensions() {
    if (window.gameCommon.isiOS) {
      var query = window.location.search.substring(1);
      var vars = query.split('&');
      var width = 0;

      for (var i = 0; i < vars.length; i++) {
        var pair = vars[i].split('=');

        if (decodeURIComponent(pair[0]) == 'width') {
          width = decodeURIComponent(pair[1]);
        }
      }

      var widthClass = '';

      if (width > 0) {
        widthClass = parseInt(width) == 620 ? 'width-620' : '';
      } else {
        widthClass = '';
      }

      $('body').addClass(widthClass);
      $('html').addClass(widthClass);
    } else {
      var dimensions = {
        width: $(window).width(),
        height: $(window).height()
      };
      var widthClass = dimensions.width == 620 ? 'width-620' : '';
      $('body').addClass(widthClass);
      $('html').addClass(widthClass);
    }
  },
  audioExt: '.mp3',
  elementsForDate: function elementsForDate(date) {
    var month = window.gameCommon.padWithZeros(date.getMonth() + 1, 2);
    var day = window.gameCommon.padWithZeros(date.getDate(), 2);
    return [date.getFullYear().toString(), month, day];
  },
  loadGameContentForDate: function loadGameContentForDate(
    date,
    success,
    error
  ) {
    var dateString =
      typeof date === 'string'
        ? date
        : window.gameCommon.elementsForDate(date).join('-');
    var storageKey = window.gameCommon.storageKeyForDate(date);
    var expirationKey = window.gameCommon.expirationKeyForDate(date);
    var foundData = window.gameStorage.getLocal(storageKey, true);
    var maxSeconds = 60 * 60 * 6 * 1000;
    // Even if online, the found data should be considered good if not older than 6 hours

    if (foundData) {
      var expiration = window.gameStorage.getLocal(expirationKey, true);

      if (expiration > new Date().getTime() - maxSeconds || !navigator.onLine) {
        success(foundData);
      }
    }

    if (!navigator.onLine) return;
    if (window.gameCommon.loadErrorCount > 10) return;
    // Client Initializer Scripts after Client Libraries
    window.gameCommon.gameMilestone('init');
    $.ajaxPrefilter('script', function(options) {
      options.cache = true;
    });
    $.ajax({
      type: 'GET',
      url: ''
        .concat(window.gameCommon.subscriptionUrl, '/d/')
        .concat(dateString, '/data'),
      cache: true,
      // jsonpCallback: 'jsonCallback',
      contentType: 'application/json',
      dataType: 'jsonp',
      success: function(data) {
        window.gameStorage.saveLocal(storageKey, data, true);
        window.gameStorage.saveLocal(
          expirationKey,
          new Date().getTime() + maxSeconds,
          false
        );

        success(data);
      },
      error: function error(jqXHR, textStatus, errorThrown) {
        console.log('Error. '.concat(textStatus, ', ').concat(errorThrown));
        window.gameCommon.loadErrorCount++;

        error(jqXHR, textStatus, errorThrown);
      }
    });
    // Client Scripts Loaded after Client Libraries
    window.gameCommon.gameMilestone('loaded');
  },
  padWithZeros: function padWithZeros(n, width, z) {
    z = z || '0';
    n += '';
    return n.length >= width ? n : new Array(width - n.length + 1).join(z) + n;
  },
  sortPopup: function sortPopup(selector) {
    $('>div', selector).tsort('', {
      attr: 'id',
      order: 'desc'
    });
  },
  // Splits an incoming date string formatted as YYYYMMDD into a variety of formats.
  splitDateString: function splitDateString(dateString, divider, format) {
    var toJoin;

    if (!format || format === 'yyyymmdd') {
      toJoin = [
        dateString.substring(0, 4),
        dateString.substring(4, 6),
        dateString.substring(6, 8)
      ];
    } else if (format === 'mmddyyyy') {
      toJoin = [
        dateString.substring(4, 6),
        dateString.substring(6, 8),
        dateString.substring(0, 4)
      ];
    } else if (format === 'mmddyy') {
      toJoin = [
        dateString.substring(4, 6),
        dateString.substring(6, 8),
        dateString.substring(2, 4)
      ];
    }

    return toJoin.join(divider);
  },
  storageKeyForDate: function storageKeyForDate(date) {
    var dateString =
      typeof date === 'string'
        ? date
        : window.gameCommon.elementsForDate(date).join('-');
    return ''.concat(window.gameCommon.gameCode, '_data_').concat(dateString);
  },
  toggleBlur: function toggleBlur(shouldBlur, action) {
    var fromClass = shouldBlur ? 'focused' : 'blurred';
    var toClass = shouldBlur ? 'blurred' : 'focused';

    if ($('body').hasClass(fromClass)) {
      action();
      $('body')
        .removeClass(fromClass)
        .addClass(toClass);
    }
  },
  expirationKeyForDate: function expirationKeyForDate(date) {
    var dateString =
      typeof date === 'string'
        ? date
        : window.gameCommon.elementsForDate(date).join('-');
    return ''
      .concat(window.gameCommon.gameCode, '_expires_')
      .concat(dateString);
  }
};

function testCSS(prop) {
  return prop in document.documentElement.style;
} // runs when document dom is ready

function retrieveAudio(fileName) {
  return window.gameCommon.gameAssetsImagePath + '/' + fileName;
}

// Sample Games
// function for showing black overlay

function checkInternet() {
  var firsttime = window.gameStorage.getLocal('firsttime', true);

  if (window.gameCommon.isiOS === true) {
    if (firsttime === null || firsttime === '') {
      // showSorry();
      // showOverlay();
      showNotice();
    } else {
      $('#sorry.popup.overlay.sorry').remove();

      if (online === false) {
        showNoInternet();
      } else {
        showNotice(); // showOverlay();
      }
    }
  } else {
    $('#sorry.popup.overlay.sorry').remove();

    if (online === false) {
      showNoInternet();
    } else {
      showNotice(); // showOverlay();
    }
  }
}

function showNotice() {
  $('#black_overlay').show(100);
  $('.overlay_notice').show(100);
  bindFirstOverlayButton();
  $('#black_overlay').animate(
    {
      opacity: 0.6
    },
    500,
    function() {
      modifyNotice();
    }
  );
}

function modifyNotice() {
  $('#black_overlay').animate(
    {
      opacity: 0.6
    },
    500,
    function() {
      $('#notice .popup_title').text('Try Our New Crossword App');
      $('#notice .popup_content').html(
        '<p>Download the app now and get 21 days of FREE access to thousands of classic puzzles, ad-free play, and more!</b></p>\n' +
          '      <p style="text-align: center;"><a href="https://itunes.apple.com/us/app/usa-today-crossword/id1445478723" target="_blank" class="apple"></a><a href="https://play.google.com/store/apps/details?id=com.usatoday.crossword" target="_blank" class="google"></a></p>\n' +
          '      <p style="text-align: center;"><button class="continue">No thanks.</button></p>'
      );
      bindFirstOverlayButton();
      $('#notice').animate(
        {
          opacity: 1.0
        },
        500
      );
    }
  );
}

function bindFirstOverlayButton() {
  $('#notice button').on('click', function() {
    $('#notice').animate(
      {
        opacity: 0
      },
      500,
      function() {
        $('.overlay_notice').css('display', 'none');
        showOverlay();
      }
    );
  });
}

function showOverlay() {
  var skill = window.gameStorage.getLocal(
    ''.concat(window.gameCommon.gameCode, '_skill2'),
    true
  );

  if (skill === null || typeof skill === 'undefined') {
    $('#offline.popup.overlay.offline').remove();
    $('.overlay').show(100);
    $('#black_overlay').animate(
      {
        opacity: 0.6
      },
      500,
      function() {
        $('#skill').animate(
          {
            opacity: 1.0
          },
          500
        );
      }
    );
  } else {
    $('#black_overlay').hide();
    $('#skill').hide();
    if (skill === 'regular') regular = true;
    else regular = false;
  }
}

function showNoInternet() {
  $('.overlay').show(100);
  $('#black_overlay').animate(
    {
      opacity: 0.6
    },
    1000,
    function() {
      $('#offline').animate(
        {
          opacity: 1.0
        },
        1000
      );
    }
  );
}

function showSorry() {
  window.gameStorage.saveLocal('firsttime', 'true', true);
  $('.overlay').show(100);
  $('#black_overlay').animate(
    {
      opacity: 0.6
    },
    1000,
    function() {
      $('#sorry').animate(
        {
          opacity: 1.0
        },
        1000
      );
    }
  );
} // delegate(bind) all the common events

var menuClick = function menuClick(e) {
  if (window.gameCommon.isiOS) {
    event.preventDefault();
    $('#input_answers').blur();
  }

  if (e.target.tagName.toLowerCase() != 'li') return;
  document.activeElement.blur();
  $('#icons > .li').focus();
  $(this).focus();
  e.stopPropagation();
  var visible = false;
  if (
    $(this)
      .find('ul')
      .is(':visible')
  )
    visible = true;

  if (window.gameCommon.isiOS) {
    $('input[type=textfield]').css('-webkit-user-select', 'none');
  }

  $('#icons .popup_menu').animate(
    {
      opacity: 1.0
    },
    0,
    function() {
      $(this).hide();
      $('#icons>li').removeClass('iactive');
    }
  );
  if (visible)
    $(this)
      .find('ul')
      .animate(
        {
          opacity: 1.0
        },
        0,
        function() {
          $(this).hide();
          $('#icons>li').removeClass('iactive');
          $('#icons .popup_menu').hide();

          if (window.gameCommon.isiOS) {
            $('input[type=textfield]').css('-webkit-user-select', 'auto');
          }
        }
      );
  else if (this.id.length) {
    $(this)
      .find('ul')
      .slideDown(10, function() {
        $('input').each(function() {
          $(this).trigger('blur');
          $(this).removeClass(''); // $(this).attr('value', '6word');
        });
        $(this)
          .parent()
          .addClass('iactive');
        $(this)
          .parent()
          .focus(); // $(this).append(keyboard_shown?'keyboard ':'nokeyboard ');
      });
  } // $(this).parent().focus();
};

togglePly = function togglePly(strt) {
  // console.log("Toggle Timer: " + strt + ", Actual: " + timer.isActive);
  if (strt) {
    $('#play').addClass('tactive');
    timer.pause();
    start = false;
  } else {
    $('#play').removeClass('tactive');
    timer.play();
    start = true;
  } // console.log("Actual: " + timer.isActive);
}; // function to count seconds

function countSecond() {
  if (runTimer) {
    var cntr = tomin(++counter);
    $('#time').html(cntr);
    $('#calendar .cur_puz .time_spent').text(cntr);
  }
} // function to convert second to hh:mm:ss format returns string

function tomin(tm) {
  var hours = Math.floor(tm / 3600);
  var minutes = Math.floor(tm / 60) - hours * 60;
  var seconds = tm - minutes * 60 - hours * 3600;
  hours = hours < 10 ? '0'.concat(hours) : hours;
  minutes = minutes < 10 ? '0'.concat(minutes) : minutes;
  seconds = seconds < 10 ? '0'.concat(seconds) : seconds;
  return ''
    .concat(hours, ':')
    .concat(minutes, ':')
    .concat(seconds);
}

function showLoader() {
  $('#ajaxloader').show(100);
}

function hideLoader() {
  $('#ajaxloader').hide();
}

if (typeof String.prototype.trim !== 'function') {
  String.prototype.trim = function() {
    return this.replace(/^\s+|\s+$/g, '');
  };
}

if (!window.console)
  console = {
    log: function log() {}
  }; // to be written/implemented in individual puzzles

// var savePuzzle = function savePuzzle() {};

// var solveLetter = function solveLetter() {};

// var solveWord = function solveWord() {};

// var solvePuzzle = function solvePuzzle() {};

// var clearPuzzle = function clearPuzzle() {};

// var afterOverlay = function afterOverlay() {}; // const performMenuAction = function(id) {
//   /** **********define this function in yourgamename.js************* */
//   /** **********given below is a mockup how it is supposed to look************* */
//   // var ele = $('#' + id);
//   // ele.parent().find('.active').removeClass('active').addClass('inactive');
//   // ele.removeClass('inactive').addClass('active');
//   // switch (id) {
//   // case 'mode_regular': $('#popup_hint').find('.content').show(100); regular = true; break;
//   // case 'mode_expert':
//   // $('#popup_hint').find('.content').hide();
//   // regular = false;
//   // $('.wrong').removeClass('wrong');
//   // break;
//   // case 'sound_on': canPlay = true; break;
//   // case 'sound_off': canPlay = false; break;
//   // case 'clock_on': togglePly(true); break;
//   // case 'clock_off': togglePly(false); break;
//   // case 'print_button': print(); break;
//   // }
// };
// function performSubMenuAction() {}

function pauseTimer() {
  // if ($('#clock_toggle .toggle_button_off').length != 0)
  // timer is running, pause it
  // $('#clock_toggle').trigger('tap');
  if ($('#clock_toggle>span').hasClass('toggle_button_off'))
    $('#clock_toggle').trigger('tap'); // if (timer.isActive === true)
  // $('#play').trigger('tap');
}

function resumeTimer() {
  // if ($('#clock_toggle .toggle_button_off').length != 0)
  // timer is running, pause it
  // $('#clock_toggle').trigger('tap');
  if ($('#clock_toggle>span').hasClass('toggle_button_on'))
    $('#clock_toggle ').trigger('tap');
}

function getPacificTime() {
  var nw = new Date();
  nw = nw.getTime() + (nw.getTimezoneOffset() - 100) * 60000;
  nw = new Date(nw + 3600000 * -7);
  return nw;
}

Date.prototype.dayDiff = function(d2) {
  var d = Math.abs(this - d2);
  return Math.floor(d / (24 * 60 * 60 * 1000));
};

function showAlert(msg, opt1, opt2, callback1, callback2) {
  $('#alert_text').html(msg);
  if (typeof callback1 === 'undefined') callback1 = 'empty';
  if (typeof callback2 === 'undefined') callback2 = 'empty';
  $('#alert1')
    .html(opt1)
    .attr('callback', callback1);
  $('#alert2')
    .html(opt2)
    .attr('callback', callback2);
  $('#black_overlay').show(50);
  $('#black_overlay').animate(
    {
      opacity: 0.6
    },
    100,
    function() {
      $('#alert')
        .animate(
          {
            opacity: 1.0
          },
          100
        )
        .show();
    }
  );
}

function showError(msg, callback1) {
  $('#alert_text').html(msg);
  if (typeof callback1 === 'undefined') callback1 = 'empty';
  $('#alert1')
    .html('OK')
    .attr('callback', callback1);
  $('#alert1').val('OK');
  $('#alert2').hide();
  $('#black_overlay').show(50);
  $('#black_overlay').animate(
    {
      opacity: 0.6
    },
    100,
    function() {
      $('#alert')
        .animate(
          {
            opacity: 1.0
          },
          100
        )
        .show();
    }
  );
}

function empty() {} // ////////////////////////////////////////////////

function disableSelect(el) {
  if (el.addEventListener) {
    el.addEventListener('mousedown', disabler, 'false');
  } else {
    el.attachEvent('onselectstart', disabler);
  }
}

function enableSelect(el) {
  if (el.addEventListener) {
    el.removeEventListener('mousedown', disabler, 'false');
  } else {
    el.detachEvent('onselectstart', disabler);
  }
}

function disabler(e) {
  if (e.preventDefault) {
    e.preventDefault();
  }

  return false;
}
