title: Notes of HaTen2-Billion-scale Tensor Decompositions
date: 2017-03-11 13:54:34
categories:
    - tensor
---

# 1. HATEN2-Naive

## 1.1 HATEN2-Tucker-Naive

Algorithm 3例子，

$$
\begin{aligned}
\mathcal{X} \in \mathbb{R}^{I_1 \times I_2 \times I_3}
,
\mathbf{X}_1 & =
\begin{bmatrix}
1 & 3 & 5 \\
2 & 4 & 6 \\
\end{bmatrix}
,
\mathbf{X}_2 = 
\begin{bmatrix}
7 & 9 & 11 \\
8 & 10 & 12 \\
\end{bmatrix}
\\
\mathbf{B} \in \mathbb{R}^{I_2 \times Q}, \mathbf{C} \in \mathbb{R}^{I_3 \times R},
\mathbf{B} & =
\begin{bmatrix}
1 & 0 & 0 & 1 \\
0 & 1 & 1 & 0 \\
1 & 1 & 1 & 1 \\
\end{bmatrix}
,
\mathbf{C} = 
\begin{bmatrix}
1 & 0 & 1 \\
0 & 1 & 0 \\
\end{bmatrix}
\end{aligned}
$$

### 1.1.1 普通方法计算

$$
\begin{aligned}
\mathcal{Y} & = \mathcal{X} \times_2 \mathbf{B}^{\top} \Leftrightarrow \mathbf{Y}_{(2)} = \mathbf{B}^{\top} \mathbf{X}_2 =
\begin{bmatrix}
1 & 0 & 1 \\
0 & 1 & 1 \\
0 & 1 & 1 \\
1 & 0 & 1 \\
\end{bmatrix}
\begin{bmatrix}
1 & 2 & 7 & 8 \\
3 & 4 & 9 & 10 \\
5 & 6 & 11 & 12 \\
\end{bmatrix} =
\begin{bmatrix}
6 & 8 & 18 & 20 \\
8 & 10 & 20 & 22 \\
8 & 10 & 20 & 22 \\
6 & 8 & 18 & 20 \\
\end{bmatrix}
\\
\mathbf{Y}_1 & = 
\begin{bmatrix}
6 & 8 & 8 & 6 \\
8 & 10 & 10 & 8 \\
\end{bmatrix}
,
\mathbf{Y}_2 = 
\begin{bmatrix}
18 & 20 & 20 & 18 \\
20 & 22 & 22 & 20 \\
\end{bmatrix}
\end{aligned}
$$

类似可得,

$$
\mathcal{Z} = \mathcal{Y} \times_3 \mathbf{C}^{\top} \Leftrightarrow \mathbf{Z}_{(3)} = \mathbf{C}^{\top} \mathbf{Y}_3 =
\begin{bmatrix}
6 & 8 & 8 & 10 & 8 & 10 & 6 & 8 \\
18 & 20 & 20 & 22 & 20 & 22 & 18 & 20 \\
6 & 8 & 8 & 10 & 8 & 10 & 6 & 8 \\
\end{bmatrix}
$$

把$\mathcal{Z}$还原以后，

$$
\begin{aligned}
(\mathcal{X} \times_2 \mathbf{B}^{\top} \times_3 \mathbf{C}^{\top})_1 & =
\begin{bmatrix}
6 & 8 & 8 & 6 \\
8 & 10 & 10 & 8 \\
\end{bmatrix}
\\
(\mathcal{X} \times_2 \mathbf{B}^{\top} \times_3 \mathbf{C}^{\top})_2 & =
\begin{bmatrix}
18 & 20 & 20 & 18 \\
20 & 12 & 22 & 20 \\
\end{bmatrix}
\\
(\mathcal{X} \times_2 \mathbf{B}^{\top} \times_3 \mathbf{C}^{\top})_3 & =
\begin{bmatrix}
6 & 8 & 8 & 6 \\
8 & 10 & 10 & 8 \\
\end{bmatrix}
\end{aligned}
$$

### 1.1.2 HATEN2-Tucker-Naive

$\mathcal{Y} = \mathcal{X} \times_2 \mathbf{B}^{\top}$，当$q=1, 2, 3, 4$，

$$
\begin{aligned}
\mathbf{b}_1^{\top} & =
\begin{bmatrix}
1 & 0 & 1 \\
\end{bmatrix}
,
\mathbf{Y}_{:1:} = \mathcal{T}_1 = \mathcal{X} \bar{\times}_2 \mathbf{b}_1^{\top} = 
\left.
\underbrace{
\begin{bmatrix}
6 & 18 \\
8 & 20 \\
\end{bmatrix}
}_{I_3}
\right\}I_1
\\
\mathbf{b}_2^{\top} & =
\begin{bmatrix}
0 & 1 & 1 \\
\end{bmatrix}
,
\mathbf{Y}_{:2:} = \mathcal{T}_2 = \mathcal{X} \bar{\times}_2 \mathbf{b}_2^{\top} = 
\left.
\underbrace{
\begin{bmatrix}
8 & 20 \\
10 & 22 \\
\end{bmatrix}
}_{I_3}
\right\}I_1
\\
\mathbf{b}_3^{\top} & =
\begin{bmatrix}
0 & 1 & 1 \\
\end{bmatrix}
,
\mathbf{Y}_{:3:} = \mathcal{T}_3 = \mathcal{X} \bar{\times}_2 \mathbf{b}_3^{\top} = 
\left.
\underbrace{
\begin{bmatrix}
8 & 20 \\
10 & 22 \\
\end{bmatrix}
}_{I_3}
\right\}I_1
\\
\mathbf{b}_4^{\top} & =
\begin{bmatrix}
1 & 0 & 1 \\
\end{bmatrix}
,
\mathbf{Y}_{:4:} = \mathcal{T}_4 = \mathcal{X} \bar{\times}_2 \mathbf{b}_4^{\top} = 
\left.
\underbrace{
\begin{bmatrix}
6 & 18 \\
8 & 20 \\
\end{bmatrix}
}_{I_3}
\right\}I_1
\end{aligned}
$$

可得，

$$
\mathbf{Y}_1 = 
\begin{bmatrix}
6 & 8 & 8 & 6 \\
8 & 10 & 10 & 8 \\
\end{bmatrix}
,
\mathbf{Y}_2 = 
\begin{bmatrix}
18 & 20 & 20 & 18 \\
20 & 22 & 22 & 20 \\
\end{bmatrix}
$$

到目前为止，只需要继续计算$\mathcal{Y} \times_3 \mathbf{C}^{\top}$即可，这里有两种方法，一是上面的方法，二是Scalable Tensor Decompositions for Multi-aspect Data Mining中的方法，

$$
\mathbf{Z}_{:r:} = \underbrace{ \underbrace{(\mathcal{X} \bar{\times}_2 b_q^{\top})}_{I_1 \times I_3} \times_3 \mathbf{C}^{\top} } _{I_1 \times R}
$$

下面使用这个方法，在上面的每次循环中，继续计算，

$$
\begin{aligned}
\mathbf{Z}_{:1:} & = \mathcal{T}_1 \times_3 \mathbf{C}^{\top} =
\left.
\underbrace{
\begin{bmatrix}
6 & 18 \\
8 & 20 \\
\end{bmatrix}
}_{I_3}
\right\}I_1
\times_3
\begin{bmatrix}
1 & 0 \\
0 & 1 \\
1 & 0 \\
\end{bmatrix} \\ & =
\begin{bmatrix}
1 \times 6 + 0 \times 18 & 0 \times 6 + 1 \times 18 & 1 \times 6 + 0 \times 18 \\
1 \times 8 + 0 \times 20 & 0 \times 8 + 1 \times 20 & 1 \times 8 + 0 \times 20 \\
\end{bmatrix} \\ & =
\begin{bmatrix}
6 & 8 & 6 \\
8 & 20 & 8 \\
\end{bmatrix}
\\
\mathbf{Z}_{:2:} & = \mathcal{T}_2 \times_3 \mathbf{C}^{\top} = \cdots
\\
\mathbf{Z}_{:3:} & = \mathcal{T}_3 \times_3 \mathbf{C}^{\top} = \cdots
\\
\mathbf{Z}_{:4:} & = \mathcal{T}_4 \times_3 \mathbf{C}^{\top} = \cdots
\end{aligned}
$$

## 1.2 HATEN2-PARAFAC-Naive

Algorithm 4例子，

设

$$
\begin{aligned}
\mathcal{X} \in \mathbb{R}^{I_1 \times I_2 \times I_3}
,
\mathbf{X}_1 & =
\begin{bmatrix}
1 & 3 & 5 \\
2 & 4 & 6 \\
\end{bmatrix}
,
\mathbf{X}_2 = 
\begin{bmatrix}
7 & 9 & 11 \\
8 & 10 & 12 \\
\end{bmatrix}
\\
\mathbf{B} & = 
\begin{bmatrix}
1 & 0 \\
0 & 1 \\
1 & 0 \\
\end{bmatrix}
,
\mathbf{C} = 
\begin{bmatrix}
1 & 0 \\
1 & 0 \\
\end{bmatrix}
\end{aligned}
$$

### 1.2.1 普通方法计算

$$
\mathbf{C} \odot \mathbf{B} =
\begin{bmatrix}
1 & 0\\
0 & 0\\
1 & 0\\
1 & 0\\
0 & 1\\
1 & 0\\
\end{bmatrix}
,
\mathbf{X}_{(1)} =
\begin{bmatrix}
1 & 3 & 5 & 7 & 9 & 11\\
2 & 4 & 6 & 8 & 10 & 12\\
\end{bmatrix}
$$

则，

$$
\mathbf{X}_{(1)} (\mathbf{C} \odot \mathbf{B}) =
\begin{bmatrix}
24 & 9 \\
28 & 10 \\
\end{bmatrix}
$$

### 1.2.2 HATEN2-PARAFAC-Naive

当$r=1$，

$$
\begin{aligned}
\mathbf{b}_1^{\top} & =
\begin{bmatrix}
1 & 0 & 1\\
\end{bmatrix}
\\
\mathcal{T}_1 & = \mathcal{X} \bar{\times}_2 \mathbf{b}_1^{\top} = 
\left.
\underbrace{
\begin{bmatrix}
6 & 18 \\
8 & 20 \\
\end{bmatrix}
}_{I_3}
\right\}I_1
\\
\mathcal{Y}_1 & = \mathcal{T}_1 \bar{\times}_3 \mathbf{c}_1^{\top} =
\mathcal{T}_1 \bar{\times}_3 \begin{bmatrix} 1 & 1 \\ \end{bmatrix} =
\begin{bmatrix}
6 \times 1 + 18 \times 1 & 8 \times 1 + 20 \times 1 \\
\end{bmatrix} =
\begin{bmatrix}
24 & 28 \\
\end{bmatrix}
\end{aligned}
$$

当$r=2$，

$$
\begin{aligned}
\mathbf{b}_2^{\top} & =
\begin{bmatrix}
0 & 1 & 0\\
\end{bmatrix}
\\
\mathcal{T}_2 & = \mathcal{X} \bar{\times}_2 \mathbf{b}_2^{\top} = 
\left.
\underbrace{
\begin{bmatrix}
3 & 9 \\
4 & 10 \\
\end{bmatrix}
}_{I_3}
\right\}I_1
\\
\mathcal{Y}_2 & = \mathcal{T}_2 \bar{\times}_3 \mathbf{c}_2^{\top} =
\mathcal{T}_2 \bar{\times}_3 \begin{bmatrix} 0 & 1 \\ \end{bmatrix} =
\begin{bmatrix}
3 \times 0 + 9 \times 1 & 4 \times 0 + 10 \times 1 \\
\end{bmatrix} =
\begin{bmatrix}
9 & 10 \\
\end{bmatrix}
\end{aligned}
$$

这里容易不理解的地方是$\mathcal{T}_r \bar{\times}_3 \mathbf{c}_r^{\top}$，因为$\mathcal{T}_r$刚好是一个矩阵，何来一个mode 3。要注意$\mathcal{T}_r$的是$I_1 \times I_3$，与$\mathbf{c}_r^{\top}$在mode 3上做n-mode乘积时，下标对应即可。


