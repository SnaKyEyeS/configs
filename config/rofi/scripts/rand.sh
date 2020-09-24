#!/bin/bash

XRANDR=$(which xrandr)

MONITORS=( $( ${XRANDR} | awk '( $2 == "connected" ){ print $1 }' ) )


NUM_MONITORS=${#MONITORS[@]}

TITLES=()
COMMANDS=()


function gen_xrandr_only()
{
    selected=$1

    cmd="xrandr --output ${MONITORS[$selected]} --auto "

    for entry in $(seq 0 $((${NUM_MONITORS}-1)))
    do
        if [ $selected != $entry ]
        then
            cmd="$cmd --output ${MONITORS[$entry]} --off"
        fi
    done

    echo $cmd
}



declare -i index=0
TILES[$index]="Cancel"
COMMANDS[$index]="true"
index+=1


for entry in $(seq 0 $((${NUM_MONITORS}-1)))
do
    TILES[$index]="Only ${MONITORS[$entry]}"
    COMMANDS[$index]=$(gen_xrandr_only $entry)
    index+=1
done

##
# Dual screen options
##
for entry_a in $(seq 0 $((${NUM_MONITORS}-1)))
do
    for entry_b in $(seq 0 $((${NUM_MONITORS}-1)))
    do
        if [ $entry_a != $entry_b ]
        then
            TILES[$index]="Dual Screen ${MONITORS[$entry_b]} | ${MONITORS[$entry_a]}"
            COMMANDS[$index]="xrandr --output ${MONITORS[$entry_a]} --auto \
                              --output ${MONITORS[$entry_b]} --auto --left-of ${MONITORS[$entry_a]}"

            index+=1

            
            TILES[$index]="Dual Screen ${MONITORS[$entry_b]} ٪ ${MONITORS[$entry_a]}"
            COMMANDS[$index]="xrandr --output ${MONITORS[$entry_a]} --auto \
                              --output ${MONITORS[$entry_b]} --auto --above ${MONITORS[$entry_a]}"

            index+=1
        fi
    done
done


##
# Clone monitors
##
for entry_a in $(seq 0 $((${NUM_MONITORS}-1)))
do
    for entry_b in $(seq 0 $((${NUM_MONITORS}-1)))
    do
        if [ $entry_a != $entry_b ]
        then
            TILES[$index]="Clone Screen ${MONITORS[$entry_a]} -> ${MONITORS[$entry_b]}"
            COMMANDS[$index]="xrandr --output ${MONITORS[$entry_a]} --auto \
                              --output ${MONITORS[$entry_b]} --auto --same-as ${MONITORS[$entry_a]}"

            index+=1
        fi
    done
done

##
# Move secondary monitors
##
t2=$(xrandr | grep " connected" | grep -v "primary" | sed -E 's/.+\ ([0-9]+x[0-9]+\+[0-9]+\+[0-9]+).+/\1/g')
if [[ "$t2" == *"+"* ]]; then
    t1=$(xrandr | grep " connected" | grep "primary" | sed -E 's/.+\ ([0-9]+x[0-9]+\+[0-9]+\+[0-9]+).+/\1/g')
    w1=$(echo $t1 | cut -d + -f 1 | cut -d x -f 1)
    h1=$(echo $t1 | cut -d + -f 1 | cut -d x -f 2)
    w2=$(echo $t2 | cut -d + -f 1 | cut -d x -f 1)
    h2=$(echo $t2 | cut -d + -f 1 | cut -d x -f 2)
    x1=$(echo $t1 | cut -d + -f 2)
    y1=$(echo $t1 | cut -d + -f 3)
    x2=$(echo $t2 | cut -d + -f 2)
    y2=$(echo $t2 | cut -d + -f 3)
    #echo "$w1 $h1 : $x1 $y1"
    #echo "$w2 $h2 : $x2 $y2"

    sm=10
    gm=100
    if [[ $x2 == $w1 ]] || [[ $x1 == $w2 ]]; then
        dy=$((y2-y1))
        ms1="${x1}x$((0<(sm-dy) ? (sm-dy) : 0))"
        ms2="${x2}x$((0<-(sm-dy) ? -(sm-dy) : 0))"
        mg1="${x1}x$((0<(gm-dy) ? (gm-dy) : 0))"
        mg2="${x2}x$((0<-(gm-dy) ? -(gm-dy) : 0))"
        mm="up"

        ps1="${x1}x$((0<(sm+dy) ? (sm+dy) : 0))"
        ps2="${x2}x$((0<-(sm+dy) ? -(sm+dy) : 0))"
        pg1="${x1}x$((0<(gm+dy) ? (gm+dy) : 0))"
        pg2="${x2}x$((0<-(gm+dy) ? -(gm+dy) : 0))"
        pm="down"
        echo "on side: $ms1, $ms2"
    elif [[ $y2 == $h1 ]]; then
        echo "below"
    elif [[ $y2 == $h1 ]]; then
        echo "above"
    fi
    TILES[$index]="Move secondary $sm px $mm"
    COMMANDS[$index]="xrandr --output ${MONITORS[0]} --auto --pos $ms1\
                      --output ${MONITORS[1]} --auto --pos $ms2"
    index+=1

    TILES[$index]="Move secondary $sm px $pm"
    COMMANDS[$index]="xrandr --output ${MONITORS[0]} --auto --pos $ps1\
                      --output ${MONITORS[1]} --auto --pos $ps2"
    index+=1

    TILES[$index]="Move secondary $gm px $mm"
    COMMANDS[$index]="xrandr --output ${MONITORS[0]} --auto --pos $mg1\
                      --output ${MONITORS[1]} --auto --pos $mg2"
    index+=1

    TILES[$index]="Move secondary $gm px $pm"
    COMMANDS[$index]="xrandr --output ${MONITORS[0]} --auto --pos $pg1\
                      --output ${MONITORS[1]} --auto --pos $pg2"
    index+=1
fi

##
#  Generate entries, where first is key.
##
function gen_entries()
{
    for a in $(seq 0 $(( ${#TILES[@]} -1 )))
    do
        echo $a ${TILES[a]}
    done
}

# Call menu
SEL=$( gen_entries | rofi -theme ~/.config/rofi/themes/nord -dmenu -p "🖵 Monitor Setup" -a 0 -no-custom  | awk '{print $1}' )

# Call xrandr
$( ${COMMANDS[$SEL]} )

# Reload polybar
echo $SEL
if [[ $SEL != 0 ]]; then 
    $HOME/.config/polybar/launch.sh
fi
