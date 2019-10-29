# Merge Intervals
# 基本问题
```
 * Given a collection of intervals, merge all overlapping intervals.
 *
 * Example 1:
 *
 *
 * Input: [[1,3],[2,6],[8,10],[15,18]]
 * Output: [[1,6],[8,10],[15,18]]
 * Explanation: Since intervals [1,3] and [2,6] overlaps, merge them into
 * [1,6].
 *
 *
 * Example 2:
 *
 *
 * Input: [[1,4],[4,5]]
 * Output: [[1,5]]
 * Explanation: Intervals [1,4] and [4,5] are considered overlapping.
```

## 思路1
首先想到的方法是遍历输入的`intervals`数组，如果元素与`ret`中的某个pair有重叠，那么就merge；否则追加到`ret`。这样得到了第一个答案，

```cpp
vector<vector<int>> merge(vector<vector<int>>& intervals) {
    vector<vector<int>> ret;
    for (int i = 0; i < intervals.size(); i++) {
        int j = 0;
        for (; j < ret.size(); j++) {
            // 如果有交集，那么取交集最两端的值，并结束当前循环
            if ((ret[j][0] <= intervals[i][0] &&
                ret[j][1] >= intervals[i][0]) ||
                (intervals[i][0] <= ret[j][0] &&
                intervals[i][1] >= ret[j][0])) {
                ret[j][0] = std::min(intervals[i][0], ret[j][0]);
                ret[j][1] = std::max(intervals[i][1], ret[j][1]);
                break;
            }
        }

        if (j >= ret.size()) {
            ret.push_back(intervals[i]);
        }
    }

    return ret;
}
```

核心代码就是注释的地方。但是这个方法忽略了一个情况是，如果`pair[0]`小的pair在后面，会出现无法merge的问题。例如：`[[2, 3], [4, 5], [6, 7], [1, 10]]`结果应该是`[[1, 10]]`，但是只能得到`[[1, 10], [4, 5], [6, 7]]`，`[1, 10]`没有机会和其他数组merge了。

## 思路2
为了避免前面的bad case，需要其他pair merge到（如果有重叠）把`pair[0]`小的pair中，由于merge是从前往后遍历的，也就是需要把`pair[0]`小的提到前面，这样`[2, 3], [4, 5], [6, 7]`才有merge到`[1, 10]`的机会。

```cpp
vector<vector<int>> merge(vector<vector<int>>& intervals) {
    vector<vector<int>> ret;

    if (intervals.size() == 0) {
        return ret;
    }

    sort(intervals.begin(), intervals.end(), [](vector<int>& a, vector<int> &b) {return a[0] < b[0];});
    ret.push_back(intervals[0]);
    for (int i = 1; i < intervals.size(); i++) {
        int j = ret.size() - 1;
        if (intervals[i][0] <= ret[j][1]) {
            ret[j][1] = max(intervals[i][1], ret[j][1]);
        } else {
            ret.push_back(intervals[i]);
        }
    }

    return ret;
}
```

# 扩展问题
如果`intervals`数组是很长的，或者是从stream中读取pair的，那应该如何实现？此时sort就不可能了，所以回到[思路1](#思路1)。思路1的好处是可以随时merge新的pair，但是`pair[0]`小的pair可能会没有机会和先出现的pairmerge。

# 总结
|                   | time complexity | space complexity |
|-------------------|-----------------|------------------|
| [思路2](#思路2)（sort） |     $$O(n\log n + n)$$            |        $$O(n)$$          |
|                   |                 |                  |
|                   |                 |                  |
