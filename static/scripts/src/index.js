var $bgs, $ol, $lis, $texts, cur = 0,
	len = 3,
	timer = null,
	isAct = false;

$(window).on('load', function() {
	init();

	timer = setInterval(function() {
		cur++;
		cur %= len;
		showItem(cur);
	}, 6000)
	$ol.on('click', 'li', function() {
		var $this = $(this);
		var index = $lis.index(this);
		if ($lis.eq(index).hasClass('active') || isAct) {
			return;
		} else {
			clearInterval(timer);
			cur = index;
			showItem(cur);
			setTimeout(function() {
				clearInterval(timer);
				timer = setInterval(function() {
					cur++;
					cur %= len;
					showItem(cur);
				}, 6000)
			}, 1000)
		}
	})

	if($.os.tablet || $.os.phone){
		$('body').swipeLeft(function(){
			if(isAct) {
				return;
			}
			
			clearInterval(timer);
			cur++;
			cur %= len;
			showItem(cur);
			setTimeout(function() {
				clearInterval(timer);
				timer = setInterval(function() {
					cur++;
					cur %= len;
					showItem(cur);
				}, 6000)
			}, 1000)
		});
		
		$('body').swipeRight(function(){
			if(isAct) {
				return
			}
			clearInterval(timer);
			cur--;
			cur = cur<0 ? cur+3:cur;
			cur %= len;
			showItem(cur);
			setTimeout(function() {
				clearInterval(timer);
				timer = setInterval(function() {
					cur++;
					cur %= len;
					showItem(cur);
				}, 6000)
			}, 1000)
		});
	}
})

function init() {
	$bgs = $('.bg .item');
	$lis = $('ol li');
	$texts = $('.textWrapper');
	$ol = $('ol');

	$bgs.removeClass('active');
	$bgs.eq(0).addClass('active')

	$texts.removeClass('active');
	$texts.eq(0).addClass('active')

	$lis.removeClass('active');
	$lis.eq(0).addClass('active')
}

function showItem(index) {
	isAct = true;
	$lis.removeClass('active');
	$lis.eq(index).addClass('active');
	$('.wrapper .active').fadeOut(300, function() {
		$(this).removeClass('active');
		$texts.eq(index).fadeIn(300,function() {
			$(this).addClass('active');
		})
	})
	$('.bg .active').fadeOut(300, function() {
		$(this).removeClass('active');
		$bgs.eq(index).fadeIn(300, function() {
			$(this).addClass('active');
			isAct = false;
		})
	})
}