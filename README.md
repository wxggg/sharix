# Sharix OS introduction
> wirrten by Xingang Wang in sep/2017

&emsp;&emsp;Sharix has the meaning of sharing, which means it is for everyone to learn and improve. The sharix os is mainly based on the `ucore os` of the tsinghua university, you can find it on github. So what i am doing is mainly about adding a graphical subsystem to it, and also makes some part of ucore as simple as possible. I will keep updating sharix os, and if you are interested in sharix, welcome to update it together. For now, the main purpose is to realize a simple desktop and window, and to realize terminal and text editing, maybe also realize the windows message mechanism.

***
## Introduction
&emsp;&emsp;I have studied `30 days to make an os` and the ucore course of Tsinghua University, so here comes a thought to my mind.I was wondering how to make a graphical os at the base of ucore using the thought of `30 days to make an os`. To be honest, the graphic part is not the essential part of operating system, there are some more important things to do. But since the important part has been done by the former people, we don't have to recreate something new which may cost much time but have little effort. So as a beginner, i take graphic part as an interest to get myself focused on the sharix project. Still, the basic and important part of operating system will be on the way.

&emsp;&emsp;I have this sharix project stored on github. You can search sharixos or sharix to find it.

## Prework
&emsp;&emsp;As we all know that operating system is actually a complex and basic program which is quite close to the hardware. So to build a simple os, we need to know about the cpu and some hardware mechanism. Otherwise it is very useful to learn the AT&T assembling language, this will be really helpful at the begin and even later part of sharix.Here are something that you may want to know before making an operating system.
* a. [C program compile and assembling](/blogs/programing&c&compile)

## Bios
At the beginning of turn on the power -- what the bios has done fore us.

## Boot
* a. [boot](/blogs/sharix&boot)
* b. [real mode and protected mode](/blogs/sharix&real_protected_mode)

## Memory
* a. [gdt](/blogs/sharix&gdt)
* b. [memory management](/blogs/sharix&memory)
* c. [paging](/blogs/sharix&paging)

## Interrupt
* a. [interrupt](/blogs/sharix&interrupt)

## Process
* a. [kernel thread](/blogs/sharix&process)

***
