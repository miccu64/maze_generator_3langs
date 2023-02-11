#!/bin/bash
# Author: Konrad Micek, Applied Computer Science, Bachelors degree 1st year

# solving maze by using Dijkstra's algorithm

findMinValue() {
    local -n visitedCellsArrayLocal lengthsArrayLocal
    local min
    visitedCellsArrayLocal=$1
    lengthsArrayLocal=$2

    local min=9999999
    local indexOfMin=-1
    local lengthsLocalLength=$(("${#lengthsArrayLocal[@]}" - 1))
    lengthsLocalLength=$((lengthsLocalLength - 1))
    for cellIndex in $(seq 0 $lengthsLocalLength); do
        cell="${lengthsArrayLocal[$cellIndex]}"
        # check value and check if key exists
        if [ "$cell" -gt "-1" ] && [ "$cell" -lt "$min" ] && ! [ "${visitedCellsArrayLocal[${cellIndex}]+abc}" ]; then
            min="$cell"
            indexOfMin="$cellIndex"
        fi
    done

    # results in Bash are returned by echo
    echo "$indexOfMin"
}

checkIndex() {
    local cell1Local=$1
    local cell2Local=$2
    local xSizeLocal=$3
    local ySizeLocal=$4

    local maxIndex=$((xSizeLocal * ySizeLocal - 1))
    if [ "$cell1Local" -gt "$maxIndex" ] || [ "$cell2Local" -gt "$maxIndex" ] || [ "$cell1Local" -lt "0" ] || [ "$cell2Local" -lt "0" ]; then
        echo "1"
        return
    fi

    echo "0"
}

getBitFromNumber() {
    local number=$1
    local bit=$2

    local D2B=({0..1}{0..1}{0..1}{0..1})
    local binary="${D2B[$number]}"
    echo "${binary:${bit}:1}"
}

argvLength=$#
grid=("$@")
if [ "$argvLength" -lt "2" ]; then
    grid=(4 5 3 0 1 4 2 5 6 5 6 9 8 12 12 6 7 9 12 8 10 5 10 3 3 0)
fi

xSize="${grid[0]}"
ySize="${grid[1]}"
xStart="${grid[2]}"
yStart="${grid[3]}"
xEnd="${grid[4]}"
yEnd="${grid[5]}"
grid=("${grid[@]:6}")

declare -A visitedCellsArray

maxLength=$((xSize * ySize - 1))
lengthsArray=($(for i in $(seq 0 ${maxLength}); do echo -1; done))
currentIndex=$((xStart + (yStart * xSize)))
# initial value for starting cell
lengthsArray["$currentIndex"]=0
destinationIndex=$((xEnd + (yEnd * xSize)))

while [ "$currentIndex" -ne "$destinationIndex" ]; do
    currentValue="${grid[$currentIndex]}"

    # check if adjacent cells are connected with this cell
    adjacentIndexes=($((currentIndex - 1)) $((currentIndex + 1)) $((currentIndex + xSize)) $((currentIndex - xSize)))
    for index in $(seq 0 3); do
        adjacentIndex=${adjacentIndexes[index]}
        result1=$(checkIndex "$currentIndex" "$adjacentIndex" "$xSize" "$ySize")
        if [ "$result1" -ne "0" ]; then
            continue
        fi

        result2=0
        # numbers and its walls (same pattern as in Python): 1 -> left, 2 -> right, 4 -> down, 8 -> up
        # bits: 0<up> 1<down> 2<right> 3<left>
        adjacentValue="${grid[$adjacentIndex]}"

        if [ "$index" -eq "0" ]; then
            result1=$(getBitFromNumber "$adjacentValue" 2)
            result2=$(getBitFromNumber "$currentValue" 3)
        elif [ "$index" -eq "1" ]; then
            result1=$(getBitFromNumber "$adjacentValue" 3)
            result2=$(getBitFromNumber "$currentValue" 2)
        elif [ "$index" -eq "2" ]; then
            result1=$(getBitFromNumber "$adjacentValue" 0)
            result2=$(getBitFromNumber "$currentValue" 1)
        else
            result1=$(getBitFromNumber "$adjacentValue" 1)
            result2=$(getBitFromNumber "$currentValue" 0)
        fi

        if [ "$result1" -eq "1" ] && [ "$result2" -eq "1" ] && [ "${lengthsArray[$adjacentIndex]}" -lt "0" ]; then
            currentLength=$((lengthsArray["$currentIndex"] + 1))
            lengthsArray["$adjacentIndex"]="$currentLength"
            #printf '%s\n' "${lengthsArray[@]}"
            for myy in $(seq 0 4); do
                for myx in $(seq 0 3); do
                    res=$((myy * 4 + myx))
                    printf '%s' "${lengthsArray[$res]} "
                done
                printf '%s\n' ""
            done
        fi
        printf '%s\n' ""
    done

    # mark as visited cell
    visitedCellsArray["${currentIndex}"]=1
    # find next index
    currentIndex=$(findMinValue visitedCellsArray lengthsArray)
done

# return results
for length in "${lengthsArray[@]}"; do
    echo "$length"
done
