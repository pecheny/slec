# slec

## Intro
Entity Or Node. Or something like that can be met often in modern game engine or framework. Role of this concept may vary from engine to engine sharing one properties and adding or eliminating another. Be a container for components, implement "composition over inheritance" principle, aid efficient data layout in memory, provide a way to separate data and logic and, in some cases, do some runtime dependency management. You know that old school "unity-way" approach to resolve dependency like this.GetComponent<>() or FindObjectOfType<>().
There are a lot of great entity-related libraries but usually them take excessive responsibility (ECS is architectural pattern so relaying on one implementation you take some architectural obligation  like you do picking one MVC-framework).

## Description

This library provides Entity implementation focusing solely on one aspect: hierarchical  context-aware runtime dependency resolving.

What **slec** Entity has:
* Can build a hierarchy i.e. tree of entities.
* Hold a number of associated components. Here Component used in figural meaning: in can be any class instance.
* Search for instance of given type within tree
* Notify when context changed i.e. entity moved to other branch or other tree

## Purpose

Imagine you implement DOM renderer. You want define globally settings like text size, color, font. But also you want be able to override these settings for some blocks.
Let Label class do all rendering stuff. Give entity reference to the label instance and treat it like ServiceLocator from within. Request settings component on entity by calling entity.getComponentUpward<TextSize>(). Default settings instance can be linked to root entity and every label in tree will get it unless its own entity has it own overriding settings component.

## Examples



