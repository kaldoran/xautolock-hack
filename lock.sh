#/bin/bash

# xautolock problem corrector by Reynaud Nicolas
# https://github.com/kaldoran


readonly CORNERSIZE=10 # Use same value use in xautolock config (default 10)

# If One of those app run, then do no run slock
isAppRunning() {
    flash_process=`pgrep -l plugin-containe | grep -wc plugin-containe`
    if [[ $flash_process -ge 1 ]];then
        return 1
    fi
    
    parole_process=`pgrep -lc parole`
    if [ $parole_process -ge 1 ]; then
        return 1
    fi    
    
    impress_run=`ps -aux | grep "soffice.bin --impress" | wc -l`
    if [ $impress_run -ge 2 ]; then
        return 1
    fi

    return 0
}

# Hack the mouse in corner
inCorner() {

    # Screen height (SCREEN_Y) and Width (SCREEN_X)
    eval $(xrandr | grep '*' | grep -o -E "[0-9]+x[0-9]+" | sed -e "s/\([0-9]*\)/SCREEN_X=\1/" -e "s/x\([0-9]*\)/\nSCREEN_Y=\1/")
    # Mouse position
    eval $(xdotool getmouselocation --shell)
    
    WIDTH_MAX=$(($SCREEN_X - $CORNERSIZE - 1));
    HEIGHT_MAX=$(($SCREEN_Y - $CORNERSIZE - 1));
    
    # Case line 131 
    # https://github.com/l0b0/xautolock/blob/93741214ba41b82ad1a6bd56ad5da28cfb4fe87a/src/engine.c
    
    if [[ ( $X -le $CORNERSIZE && $X -ge 0 && $Y -le $CORNERSIZE && $Y -ge 0)
       || ( $X -ge $WIDTH_MAX && $Y -le $CORNERSIZE )
       || ( $X -le $CORNERSIZE && $Y -ge HEIGHT_MAX )
       || ( $X -ge $WIDTH_MAX && $Y -ge $HEIGHT_MAX ) ]]; then
       
        return 0;
    fi
    
    return 1;

}

if inCorner; then
    slock;
fi

if isAppRunning; then
    dpmsStatus=`xset -q | grep -ce 'DPMS is Enabled'` # DPMS is at 1 if you check "Presentation mod"
    if [ $dpmsStatus == 1 ];then
        slock;
    fi
fi

# Here is my command :D
# xautolock -detectsleep -time 1 -locker "~/lock.sh" -nowlocker "slock" -notify 30 -notifier "notify-send -t 5000 -- 'Lock screen in 30 seconds'" -corners 000+ -cornerdelay 3