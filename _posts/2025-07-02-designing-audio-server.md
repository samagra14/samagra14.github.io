---
layout: post
title: "Designing an optimised Audio Inference Server"
description: My thoughts and notes while creating an audion inference server for Tensorfuse.
categories: Philosophy
author: Samagra Sharma
---

At Tensorfuse we have a lot of voice AI customers that need to host their entire pipeline on EKS. An end to end voice AI pipeline
usually consists of a Speech to Text (STT) model, an LLM model for RAG or function calling, and a Text to Speech (TTS) model. There are 
already APIs that provide these services with closed source models like Deepgram or OpenAI's audio models. However, when it comes to
hosting open source models, there is much little information around inference optimisations and operational considerations such as
scaling, routing etc.

### 2nd July 2025

The LLM ecosystem is quite mature compared to voice models where they have inference servers like vLLM that can be orchestrated on
Tensorkube like platforms pretty easily. However when it comes to voice models, no such server exists. This id my attempt to create a small
server that can host STT and TTS models pretty easily and can be orchestrated on Tensorkube like platforms.

To figure out the design of the server, I will first need to understand how these models are consumed in Agent Orchestrators like Pipecat
and Livekit. This will give me an idea of the API protocol layers and the data formats that need to be supported. For instance I will
need to support some sort of streaming API for STT and TTS models. I will also need to have a target TTFB and TTFT for the models.

So the plan is to first actually build a couple of voice agents using Pipecat, then write a script that can benchmark the TTFT and TTFB tokens
for various parts of the pipeline and then use that to design the server. I am slightly worried of the fact that 
Triton doesnt support websockets and / or webRTC. To be honest I have never read about WebRTC so I would have to understand that first as well.

#### Pipecat experiments

#### Benchmarking existing APIs and models.

#### Designing the interface of the server

#### Figuring out how the server works with Pipecat

#### Measuring the performance of the server
