---
layout: post
title: "Designing an optimised Audio Inference Server"
description: My thoughts and notes while creating an audio inference server for Tensorfuse.
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

Pipecat has a [great library of examples](https://github.com/pipecat-ai/pipecat/tree/main/examples/foundational) to get started with voice agents
I am gonna implement a few of them to understand the overall picture. Here's what I learned relevant to the server design:

Pipecat has three core components - Frames, Pipelines and Processors

Processors are workers that are individually responsible for one thing -
* Converting received audio to text throughout the interaction 
* Converting text to audio throughout the interaction
* Running the LLM model to generate responses throughout the interaction

Think of them as listeners that listen for some input and spit some output. And each one continues to listen throughout the interaction

Now, `Frames` are the data that is passed between these processors. They are like the messages that are sent between the processors.
For eg, if the LLM outputs - 'Hi This is Samagra, how can I help you?', then the LLM processor will output individual tokens like 'Hi', 'This', 'is', 'Samagra',
as frames to the TTS processor. The TTS processor will then convert these frames to audio and send them to the client. The output frames of the TTS processor
will be a collection of audio chunks (as opposed to converting each individual token frame to audio).

I am assuming that Pipecat handles this breaking into frames logic as I dont want to implement that in the server. And as far as communication with the 
server is concerned, I will most likely need to understand how each of these workers communicate with the server, take that as an API spec and build from there.




#### Benchmarking existing APIs and models.

#### Designing the interface of the server

#### Figuring out how the server works with Pipecat

#### Measuring the performance of the server
