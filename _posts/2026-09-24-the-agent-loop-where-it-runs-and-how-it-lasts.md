---
layout: post
title: "The agent loop, where it runs, and how to make it last"
description: An agent is a clerk, a model, and a spare room for commands. This essay says where each part lives, what each placement costs, how each part fails, and how a durable record lets the same session continue after a crash.
categories: Tech
author: Samagra Sharma
---

<style>
  .post-content figure { margin: 1.6em 0 2em; }
  .post-content figure img { width: 100%; height: auto; border: 1px solid #e7e5e4; border-radius: 8px; background: #fbfaf7; }
  .post-content figcaption { margin-top: 0.7em; line-height: 1.55; }
</style>

You ask a program to add a test that fails when the login form accepts an empty password. That program is the harness: the clerk that keeps the task moving. It sends your sentence, together with a record of what has already happened, to a language model, which is a program that writes the next reply from the text it was given. The text the harness sends is the prompt. The model writes a message back to you, or it asks for an action, such as reading the login form, editing a test file, or running the tests. The harness carries out the action, attaches what happened, and asks the model again. That cycle is the agent loop. One sentence from you can lead the model to request many actions before it is ready to talk to you.

OpenAI, the company that makes Codex, describes the stretch from your message to the model's message back as one turn. Codex is their coding agent, the program that edits a project by walking this loop. A turn often contains a long stretch of actions in the middle. The login-form task is one turn when the model finishes the test and then tells you so. It becomes another turn when you reply "also cover a password that is only spaces" and the cycle starts again.

Five things make the cycle something you can point at. A sandbox is the spare room where commands are allowed to change files. The harness is the program that keeps asking the model what to do and keeps the record. A tool is one named action the model can request. An environment is everything a running program can see: the files, the installed programs, the secrets, and the network rules. The harness has an environment, and the sandbox has an environment. They can sit on the same computer and still be different views, because one of the programs is wrapped in a rule that hides part of the machine.

## The sandbox is a spare room for the command

A sandbox is a place set aside for the actions. It has files, a way to start programs, and rules about which network addresses those programs may open. The login-form project lives there, and so do the compiler, the program that runs the tests, and any password the test needs in order to start the app.

On a laptop, that place is usually one restricted program on the same computer you are typing on. A rule attached to the command hides the rest of the computer: it lists which files the command may touch and which network addresses it may open. Codex and Claude Code, which is Anthropic's coding agent, wrap the shell this way. The shell is the program that runs typed commands. The process that lives in the room is the command the model asked for, together with any programs that command starts. A process is simply a running program.

In a cloud agent, the sandbox is usually a separate virtual machine on the company's computers. A virtual machine is a whole computer simulated in software, with its own operating system, running on someone else's hardware. Cursor, the editor that also runs agents in its cloud, gives each cloud agent a small machine of this kind, walled off from Cursor's other services. The process in the room is still the command, and the computer belongs to Cursor.

The room exists so that a broken install, a full disk, or a test that left the project in a bad state stays inside it. Deleting the room hands you back a clean machine. That is why the placement of the harness matters: the clerk has to live somewhere that deleting the room leaves in place.

## The harness is the program that keeps the loop going

The harness accepts what you typed, builds the prompt, sends it to the model, and reads the reply. When the reply asks for a tool, the harness performs the tool and appends the output, the exit code (the number a command returns to say whether it succeeded), and a note of which files changed. It stores the transcript, which is the ordered record of your messages, the model's messages, and the tool results, and it decides when the cycle should stop.

On a laptop, the harness is a process you started. Claude Code, or Codex, is running in your terminal, on your computer, under your user account, and that process is the clerk. The shell it starts is a different process, placed in the sandbox.

In Cursor's cloud, the loop lives in Cursor's own service, on Cursor's computers. Their public notes say they keep three things separate: the agent loop, the state of the machine, and the conversation. The agent loop lives in Temporal, which is a system that stores a log of a long-running task so the task can continue after the process doing the work has exited. The virtual machine is a different computer. Cursor set it up this way so they can put a machine to sleep, replace it, or point the loop at a different kind of machine, while the conversation stays where it is.

Codex on the web places the harness inside the container. A container is a packaged set of files and running programs that shares the host computer's operating system. OpenAI's description says a worker, which is a program on their side, prepares a container that already has your project checked out, starts the harness program inside that container, and keeps a connection to it open. Your browser talks to OpenAI's servers, and those servers pass along the events from the worker. The loop process shares the container with the files. The worker and the saved transcript sit outside the container, which is why closing the browser tab leaves the task running.

## A tool is one named action

A tool is an action with a name and a set of details the model fills in. "Run this command in this directory." "Read this file." "Replace this span of text." The harness is responsible for doing the thing and returning what happened.

A tool runs wherever the harness sends the work. The tools that touch the project run inside the sandbox, and their process is the restricted command. For the login-form task, that means reading the form, writing the test, and running the tests.

A few tools are calls the harness makes on its own side of the wall. In Codex, web search is performed by the model service, and OpenAI's writeup says the sandbox description applies to the shell tool. Other tools, such as those from a server you attached yourself, have to apply their own limits. In Cursor's cloud, tool servers that are reached over the web are called through Cursor's backend, so the virtual machine receives the result and the secret for that server stays off the machine. Claude Code's file tools run inside the Claude Code process, and permission rules limit which paths they may touch, because those tools read and write particular paths. The shell, which can do anything a shell can do, is the tool they place in the sandbox.

So the rule that matches these products is a specific one. Actions that change or inspect the project run inside the sandbox. Actions that are really a call to some other service run beside the harness, or the harness makes the call and passes the result inward, and the sandbox receives that result.

## An environment is what a process can see

An environment, here, means the files, the installed programs, the secrets, and the network rules visible to a process while it runs. Two processes on one laptop can have different environments when a rule hides part of the machine from one of them.

The harness environment is the view from the harness process. It includes the transcript, the secret used to call the model (the key that pays for each reply), the settings of the loop, and the network path to the company that runs the model. On your laptop, that view is your user account. Codex keeps its settings in a folder under your home directory, and the login that reaches the model lives with the program you launched. In a cloud agent built like Cursor's, that view is the worker that runs the workflow. A workflow, in Temporal, is the program that lists the steps of a long task and is started again from the log when a worker exits. The virtual machine is a separate computer, and the model key stays with the worker.

The sandbox environment is the view from inside the spare room. It includes the checked-out project, the compilers and libraries, the secrets you placed there because the tests read them, and the network the commands are allowed to use. On a laptop, that view is the rule wrapped around the shell. In a cloud agent, that view is the virtual machine: its disk, the list of programs running on it, and the rules for traffic leaving it.

The loop is the harness asking the model, the model asking for a tool, and the tool running in the sandbox. The two environments decide what each side is allowed to see. The model itself runs on the model company's computers, in the process that answers their web service. That service holds the model, and it sees the prompt the harness chose to send.

<figure>
  <img src="/assets/images/agent-loop-where-each-part-lives.svg" alt="A diagram of you, the harness, the model, and the sandbox, with the computer and the process named on each part.">
  <figcaption>The harness process asks the model what to do next, and the sandbox is the room where the requested command runs. On a laptop those are two processes on your computer. In a cloud agent they are often two computers.</figcaption>
</figure>

## Putting the harness inside the sandbox ties the session to that machine

Put the harness process inside the sandbox environment and four costs arrive together. Codex on the web accepts those costs on purpose, because one program file then sits next to the project both in the cloud and on a laptop, and the costs are still paid.

The session lasts as long as that sandbox. The transcript, when it lives in the harness process or in files on that machine, ends when the machine is recycled. Cloud companies recycle these machines on purpose. An idle machine costs money every minute, so the operator shuts it down and starts a fresh one when you send the next message. Cursor wrote that they moved the loop off the virtual machine so the machine's life could move on its own: sleep it, replace it, or point the loop at a different kind of machine. When the loop stays on the machine, recycling the machine recycles the clerk. Continuing the login-form task means starting a new harness and handing it a copy of the conversation, in the case where you stored a copy somewhere else.

The model key sits in the sandbox environment. The harness presents that key on every call to the model, so the process environment, a settings file, or the process memory holds it. A command the model requested runs in the same room and can print the environment or read the settings file. Products that place the program and the shell in one room then add a second lock. Codex marks its own settings folder, and the hidden folder that records the project's history, so the sandboxed shell can read them and a write from the shell is rejected, even while the project itself can be edited. A command then has a hard time rewriting the program that is supervising it. That lock is an ongoing cost, because every new place a secret might land has to be covered. A command that runs with the lock lifted sees the room as it is, secrets included.

Replacing a stuck sandbox replaces the harness. The tests filled the disk, or a package install broke the system tools. You start a new machine, check the project out again, start a new harness, and read the saved transcript back into it. You pay for the fresh start, and you pay for that reading-back, and any plan that existed in the old process's memory is gone. There is a quieter cost during the minutes the model is writing. The process waiting for the reply is the harness, and the harness is on the development machine, so the machine stays powered, with its processors, its memory, and its disk, for the whole wait. You pay for a full development machine while the model writes, because the process that has to stay alive to receive the reply is sitting on that machine.

The program that checks the work shares a disk with the work. A command can edit the checker, read its logs, or change its rules, in the case where those files can be written from the shell. Setting those files so a write is rejected is how you keep the checker intact, and you maintain that setting for as long as the product exists.

A worker can still stand outside the container, the way OpenAI's web setup does, holding the connection and a saved transcript so a new browser tab can catch up. That worker keeps the browser from having to stay open. The loop process, the one that calls the model and decides the next shell command, is still inside the room that a full disk can take down.

## Putting the harness outside the sandbox makes every action cross a boundary

Put the harness process outside the sandbox and a different set of costs arrives. They are the costs of a boundary, and they are the costs Cursor's cloud agents and the laptop programs pay.

Every tool call crosses the boundary. The harness sends the command through a local pipe, or over the network to the virtual machine, and waits while the command runs and the output comes back. A task that reads many small files pays for the trip many times. On a laptop the trip is the cost of starting a restricted process, and it is small. Between the service that runs the loop and a virtual machine, the trip includes a network round trip and the time to copy the output. A long test log moves across that line, and the harness decides how much of it to show the model.

The harness holds one picture of the files, and the sandbox holds the files. After a command changes the project, the harness learns what changed and puts that into the next prompt. When the harness sends the next prompt from the old picture, the model reasons about a project the sandbox has already left behind. Keeping the two pictures honest is ordinary work, and you do it on every step of the login-form task.

You run two environments for the session. The harness environment stays up with the transcript and the model key. The sandbox environment holds the project and the secrets the tests read. Those test secrets still enter the sandbox, because the test process reads them there. The split places the model key on the harness side. Cursor's web tool servers follow the same split: the backend holds the secret, performs the call, and the virtual machine sees the result.

You also pay to bring a sandbox into existence and to put it away. A fresh virtual machine copies the project and installs dependencies before the first command. Teams shorten that wait with snapshots, which are saved copies of a disk, and with machines that are already warm. They build ways to save a disk, restore it, and copy it so a second machine can start from the same files, and they sleep machines between messages. Cursor's notes describe that work as the way to keep the machine's life separate from the loop's life. The machinery costs money and engineering time, and that cost is the price of a session that survives a machine.

Some tools sit awkwardly in a locked room, and the earlier rule still holds. A web search, or a call that needs a private token, belongs with the harness, or with a stand-in the harness controls. The sandbox then receives the result. The tools that touch the project stay inside.

<figure>
  <img src="/assets/images/harness-inside-and-outside.svg" alt="Two layouts. In the first, the harness and the tools share one machine. In the second, the harness and the model key sit above a replaceable sandbox.">
  <figcaption>When the harness shares the sandbox, the session ends with that machine, and the model key sits where the shell can read it. When the harness stays outside, every command pays for a trip, and replacing the machine leaves the session in place.</figcaption>
</figure>

## The harness belongs outside the sandbox, and the project tools belong inside it

The placement you can count on is the one Cursor uses for cloud agents and the one Claude Code and Codex use on a laptop. The harness runs outside the sandbox. The tools that touch the project run inside it.

The session outlives any one sandbox. The transcript and the next step live with the harness. When a machine gets stuck during the tests, you destroy it, start another, check the branch out, and hand the new machine to the same harness. The conversation about the login form continues. In Cursor's cloud this is the normal path: the loop stays in the workflow system, the machine can go away while you are idle, and a later message brings a machine back and starts it with the saved conversation.

The model key stays in the harness environment. The sandbox receives the project and the particular secrets a test needs. A command can read those test secrets, because you placed them there for the test. The command runs in a different process, and in the cloud on a different computer, from the key that pays for the model.

Replacing a sandbox is a routine step with a known price. You pay for a new start, or for restoring a snapshot. You keep the plan, the transcript, and the step the model was about to take.

The laptop products already split the processes on one computer. The program you launched is the harness, in your user session. The shell runs under a rule that hides the rest of the computer. Anthropic also documents a stricter setup that places the entire Claude Code process inside a container, so the file tools and the helper programs share that container too. That setup is the inside placement, and it is the one you reach for when you want a single wall around every helper. The everyday design is the split: the clerk in your session, and the shell in the restricted process.

OpenAI's guide to sandbox agents draws the same line in plain roles. The harness is the side that decides. It owns the loop, the calls to the model, the routing of tools, the approvals, and the record that lets a run continue. The sandbox is the side that computes. It owns files, commands, network ports, and snapshots. They describe keeping sign-in, billing, and the recovery record on the deciding side, and they describe running the harness inside the sandbox as a convenient layout for a prototype, one that puts both jobs inside a single boundary. Codex on the web is the public product that starts the harness program inside the workspace container, so the same program runs next to the files in the cloud and on a laptop. A worker outside prepares that container and holds the connection, and a saved transcript lets a new browser tab catch up. The shell is still placed under a further rule inside that container, with the harness's own folders set so a write from the shell is rejected. That design buys one program and one layout of files. For a session whose machine you expect to throw away, the outside placement is the one that makes the session the thing that lasts.

Those same parts can fail while the login-form task is running. An older kind of record, built for payments and orders, is what lets the outside placement keep its promise after a crash.

## Each part of the loop can fail, and the failure lands in a different place

Go back to the login-form task and let one piece fail at a time.

The model company's process can fail while the harness is waiting. The service answers that you have sent too many requests, or that it is overloaded, or it accepts the connection and then closes it after half the reply has arrived. The reply was arriving in pieces, which is what people mean when they say the model is streaming. The harness holds a partial reply and a gap where the rest should be. A retry asks the model to write a new draft. The words from the failed attempt and the words from the successful attempt are two different drafts. Temporal's notes on streaming agents make this visible on purpose: a person watching the live text sees the failed attempt and then the retry, while the workflow's stored result keeps the attempt that finished.

A length error is a different kind of failure from the model service. The prompt, which includes the whole transcript and the latest test log, is larger than the model will accept for one call. The model measures that size in tokens, which are the small pieces it splits text into, and the maximum it will accept is called the context window. Sending that same prompt again meets the same limit. The harness has to shorten the transcript and then call the model with the shorter one. While that shortening is still unfinished, the login-form task waits on the harness's side of the wall, and the sandbox sits idle with whatever files the last command left behind.

The tool can fail in the harness before any command runs. The model names a tool outside the set the harness implements, or the details are the wrong shape, a single path where a list of paths was required. The harness records an error as the tool result and asks the model again. The tool can also fail inside the sandbox: the tests exit with a failure, or the file the model asked to read is absent from the project. That result is what the model needs, because the model is supposed to read it and change the test. It becomes harmful when the harness shows the model a shortened log and the model treats the quiet ending as success.

The sandbox can fail around the tool. The room runs out of memory in the middle of the test run, and the operating system stops the process. A write of the test file is cut off, and the file on disk is half saved. Or the platform shuts the virtual machine down because it looked idle during the long model call, and the next tool request has nowhere to land.

The harness can fail as a process. You close the laptop, and the local program exits. Or a cloud worker is replaced by a new version while it was waiting. Whatever lived in that process's memory, and had yet to be written into a record elsewhere, is gone. Whatever had already been written into a record elsewhere is still there. That difference is what the last part of this essay is about.

<figure>
  <img src="/assets/images/where-each-part-fails.svg" alt="Four stacked regions showing a failed model call, a failed harness, a failed tool, and a failed sandbox.">
  <figcaption>A failed model call pauses the task in the harness, a failed harness drops the in-memory plot of the thread, a failed tool returns an error or a misleading log, and a failed sandbox takes the files with it.</figcaption>
</figure>

## The harness fails by losing the thread after the model call has returned

A failure from the model service is something the harness can often try again. The wider failures are the ones the harness creates while it is doing its job.

The context window comes first. Every model accepts a maximum amount of text for one call, counting both the prompt and the reply. OpenAI's essay on the Codex loop points out that a single turn can contain hundreds of tool calls, and that keeping this text within the limit is the harness's job. Codex's approach is to compact the conversation once the size crosses a threshold. Compaction is a shortening step: it replaces the input with a shorter list that still represents what happened. One item in that shorter list is a packed note the model can use later as a memory of the longer conversation. The login-form task continues from that shorter list.

Compaction is itself a call to the model service, and that call can fail. Public reports from Codex sessions show the shapes this takes. The shortening request can be larger than the window it was meant to relieve, so the service returns a length error for the rescue step. The decision to shorten can be based on the last size the server reported, which leaves out a large tool result the harness has just attached, so the next ordinary call is the one that overflows. The connection can close during the shortening call. After any of these, a short follow-up from you, on the same thread, can meet the same error. The process is alive and the transcript is on disk, and the thread still turns away new work, because every path back to the model begins with a prompt the service rejects. Recovery is a new, shorter record of the task, or a new session started from the current files and a restatement of the goal. A harness that retries the identical shortening forever keeps the session looking busy while the task stands still.

A second failure is a loop that lengthens the transcript while the project stays as it was. The tests fail because they look for the wrong part of the page, the model runs the tests again, and the log is attached again, until the context window fills with copies of one error. From the outside the agent is working, and the login form is unchanged.

A third failure is a false success the harness creates by keeping too little of the log. The command wrote ten thousand lines and the harness kept the last forty. The failure was on the first page. The model sees a quiet ending and reports that the test passed. The repair is a rule about what "the result" includes: the exit code, a pointer to the full log, and enough of the failing lines for the model to choose the next edit.

A fourth failure arrives inside a tool result that otherwise looks ordinary. A file in the project, or a web page the command printed, contains a sentence aimed at the model, telling it to drop the login-form task and print the environment. The harness pastes command output into the prompt as an observation of what happened. The model can treat that sentence as a new instruction. The sandbox rule limits what the command can read. The harness's job is to keep treating tool output as data about the world, and to keep the model key in an environment the command is describing from the outside.

A fifth failure is a retry that repeats a change. The model call succeeded, the harness started the tests, the tests rewrote a cache file, and then the worker died before the result was stored. The new process retries the turn from the last stored mark and starts the tests again. Two test runs now race on one project. The record has to include the tool result before the harness is willing to forget the process that produced it. That requirement is older than agents. It is the same requirement a payment system has, which is why the next section is about a log of finished steps.

## Sandboxes come in a few kinds, and each kind fails in its own way

The word sandbox covers four common rooms. They differ in what they share with the computer that hosts them, and the failure follows from what they share. The kernel is the part of the operating system that every program on that computer shares. Remembering that one fact makes the four rooms easy to tell apart.

A restricted process shares your kernel and your machine. The laptop sandbox is this kind, and it starts almost immediately, because it is an ordinary process with a rule attached. Codex and Claude Code put the shell here. The rule lists which files and which network addresses the command may use. It fails when the rule blocks a request a compiler or a certificate check expected to make, which is why some command-line tools are awkward under the rule and get listed as exceptions. A second failure happens when the helper that applies the rule is absent. The command then runs with your user account's permissions, and it can see the rest of your computer. Claude Code can be set to refuse to launch when that helper is absent, because the absence would turn every shell command into an ordinary command in your session. Inside a container that itself has limited rights, the helper often fails to build a fresh list of running programs. The documented adjustment is to reuse the outer container's list, and that is a weaker room, acceptable when the outer container is already the wall you trust.

A container has its own files and its own list of processes, and it shares the host kernel. Docker is a common way to run one. The image is the starting set of files: a base system, plus the language, plus the project. The container fails when a memory limit or a disk limit is hit, when the program that runs containers stops, or when the image lacks the program the model just named. The tests show the mismatch clearly. The model has seen that test command in a thousand projects, the image was built for a different language, and the command fails immediately. The model may then try to install the missing tool, which fills the disk or reaches a network the rule has closed.

A stand-in system puts a program of its own in front of the command's requests to the operating system. That program answers the requests, and the real kernel receives a narrow set. Some programs behave differently because the stand-in answers a request in its own way. A test that passes on your laptop and fails in this room is a sandbox failure, and the process still exits with its own status code. The room is running, and the command behaved differently from the same command on your laptop.

A small virtual machine has a kernel of its own. Cursor's cloud agents use a machine of this kind for each agent. A full virtual machine, the ordinary cloud computer you would rent by the hour, is the same idea with a slower start. The machine fails the way any computer fails: it runs out of memory, it runs out of disk, its operating system crashes, or its network connection goes away. The platform adds failures of its own. It shuts the machine down after the machine has sat idle. Restoring a snapshot can fail, and the new machine comes up with an empty disk or with a disk from the wrong moment. Because the harness is on another computer, those failures take the room and leave the transcript.

<figure>
  <img src="/assets/images/kinds-of-sandboxes.svg" alt="Four panels describing a restricted process, a container, a stand-in for the operating system, and a small virtual machine.">
  <figcaption>A restricted process, a container, a stand-in for the operating system, and a small virtual machine each wall the command off from the computer that hosts it, and each one fails when its own limit is hit or when a program inside it behaves differently from the same program on your laptop.</figcaption>
</figure>

The login-form task makes each failure concrete.

The harness has a time limit on the shell. The tests hang because they started a browser and left it open. The time limit fires, and the harness records "timed out" as the tool result and asks the model what to do. The browser may still be alive in the room, holding a lock on its files, so the next test run fails for a new reason. A careful harness stops every program the command started when the time limit fires, and it says so in the result.

The memory limit stops the tests while they are writing a coverage file, which is a file that records which lines ran. The test file the model edited is complete, and the coverage file is partial. The model reads the partial file and repairs it into something the next run trips over. The clean recovery throws the room away, restores a snapshot taken after the last successful command, and runs the command again.

When the machine is gone, the next tool step returns "the room is gone." With the harness outside, that error is a step the harness understands: create a room from the last snapshot, then look at whether the command that was still running had a result stored. With the harness inside, the error takes the clerk with it, and the saved transcript on some other disk is the way back.

The room fails because of a limit, because the image and the command disagree, or because the computer hosting it took the room away. Compilers and browsers use more memory than a limit sized for a small script. The agent itself fills the disk with downloaded libraries, build caches, and logs. A sandbox nested inside another sandbox finds that a list of processes it expected is absent. Installing a new version of the host, or an idle policy, deletes a machine that was waiting on the model. The model can be right about the edit, and the room can still run out, because the room is a computer.

## Long-running work needed a record that outlives the process

The failures above share a shape. A process was in the middle of a sequence, the process went away, and the sequence had changes in the outside world that need to happen a single time. Agents made the shape familiar, and payment systems and order systems met it first.

Consider a checkout that has to charge a card and then ask a warehouse to ship the item. A program on a server does both calls. The charge succeeds, and the process is killed when a new version of the program is installed, before the ship call starts. A new process that simply runs the program from the top charges the card again. A new process that stops there leaves the customer charged and the box unsent. A row in a database that says "charged" carries the sequence when every crash writes that row, every new process reads it, and the database row and the bank call agree in the case where the bank's response was lost on the way back. Teams that build this by hand grow a private engine of retries, time limits, and flags that mean "where was I." The engine has bugs at the boundaries, because the boundaries are exactly where the process died.

A durable execution platform is that engine, built once, with a specific promise. The code you write looks like the sequence: charge, then ship, then wait two weeks and ask how the delivery went. The platform stores a log of the sequence outside the process. When the process dies, another process loads the log and continues.

Uber built an internal system called Cadence for backend jobs that had to finish after the machine doing the work was gone. Temporal is the later open-source system that grew out of that work, led by the people who built Cadence. The same shape shows up anywhere a business process is longer than one web request: an order, a payout, an account being set up, an approval that a person will answer tomorrow. The platform is older than the agent loop. The agent loop is a new caller of it.

## The platform records every finished step and resumes from that record

Temporal's service stores an event history for each workflow. The history is a log with lines such as "workflow started, order 4812," "charge step completed, payment id stored," and "ship step scheduled." The worker, which is a process that runs your workflow code, can exit. A different worker can pick the workflow up, because the log lives in the service.

Recovery works by replay, which means the new worker runs your workflow code from the top. Each time the code reaches an activity that already has a result in the log, the platform returns that result and moves on. An activity is one step that touches the outside world, such as calling the bank, and whose result is written into the log. The code then reaches the first activity that still has an opening in the log, and that activity runs for real. In the checkout, the charge step returns the stored payment id, the bank is left alone on this replay, and the ship step starts.

Activities are tried again when they fail, and a retry can perform the outside change more than once. The charge call can succeed at the bank, the response can be lost, the history then has an opening, and the retry charges again. The practical answer is a repeat label that you send with the activity. People in payments call this an idempotency key, and the order id is a natural one. The bank stores the first charge under that label and returns the same payment id when the label arrives again, and the history records that one result. The promise you can explain to someone else has three parts. The workflow code runs through to the end across crashes. Finished activities return their recorded results on replay. An outside change stays single when the activity carries a repeat label that the other system honors.

Timers are records in the same log. "Wait 14 days" is a timer stored by the Temporal service. The worker is free to exit for those 14 days. When the timer fires, a worker loads the history and continues with the email activity. A signal is a message from outside, such as a note the warehouse's system sends when someone scans the box. The signal is stored if it arrives while every worker is busy or stopped, and it is delivered on the next replay that reaches the wait.

The workflow code has to take the same path when it is run again, because replay runs it from the top. People call that property determinism. A branch that depends on a fresh random number, or on reading the clock on the wall directly, can take a different path on replay from the path the history recorded, and the log and the code then disagree. Temporal gives the workflow a clock and a random source that are written into the history, so replay sees the same values. Ordinary code that calls the bank, reads a file, or asks for the time belongs in an activity, where it runs once and the result is stored.

When you later change the order of steps, replay of old checkouts still has to match the history those checkouts recorded. You label the changed stretch of code. Workflows that started before the label keep the old order. Workflows that start after the label take the new order. Installing a new worker in the middle of a checkout is safe, because the history, together with the label, tells the new process which sequence to follow.

<figure>
  <img src="/assets/images/durable-replay.svg" alt="Workflow steps beside an event history. After the worker exits, a new worker returns the recorded charge and starts the ship step.">
  <figcaption>After the worker exits, a new worker replays the workflow from the event history. The charge that already has a recorded result comes back from that history, and the ship step is the one that runs.</figcaption>
</figure>

You build on this with three pieces.

You write the workflow as a function that calls activities in order and waits on timers and signals. You write each activity as a function that does one outside change and returns a result. You run a worker that asks a queue for the next piece of work, runs the workflow code, and runs activities. The Temporal service, which you can run yourself or use as Temporal's hosted service, stores the history and decides which worker should take the next step. Your application code stays the sequence. The log, the retries, and the waits live in the service. This is the tool people used for orders and payments, before anyone called the sequence an agent. An agent session is a sequence with the same shape: a model call where the charge was, a shell command where the ship was, and a person who may answer tomorrow where the delivery question was.

## After the model arrives, three different things are worth making durable

The agent session, the sandbox, and the acts around them fail on their own, so each one becomes durable through its own record.

The session is the record on the harness side. It includes the items in the thread, the tool call that is in progress, any approval you still owe, and the position of the loop. OpenAI's sandbox guide calls this run state: the model's messages, the tool state, the approvals, and which agent is active. Making the session durable means this record lives outside the harness process. A crash of the process loads the record and continues. Codex on your laptop already stores a thread on disk and can resume it with its resume command. That record survives the process and lives on the same disk as the machine. A durable session in the stronger sense survives that disk too, because the record is a log on another service.

The sandbox is durable in two different ways, and mixing the two up is how a restore comes back wrong. Session state is a written-down handle that reconnects to the same live room. A handle is the information you need in order to talk to that room again. The files, the running programs, and the open ports are still there, because the machine is still there. A snapshot is a saved copy of the files, used to start a fresh room. The old machine can be gone. The new one starts from the saved files, with a new list of processes. OpenAI's guide lists them as separate records, and their runner looks for a live session first, then stored session state, then a snapshot, and then a brand-new room built from a description of the starting files. Cursor's cloud agents spend their effort on the snapshot side: sleeping a machine and waking it, saving a disk, restoring it, and copying it so a second machine can start from the same files, while the loop and the conversation stay in the workflow system. A sleeping virtual machine is close to session state, because you intend to wake the same machine. A saved disk you can copy onto a second machine is a snapshot. You want both, and you want the session record to say which one is current.

The acts around the session are the model call, the shell command, the snapshot itself, the message that tells you the test exists, and the approval you will give at breakfast. Each act can succeed, and the response can be lost, which is the charge-card problem again. Each one becomes an activity with a repeat label, a time limit, and a recorded result.

The techniques follow from those three records.

For the session, store the thread items in the workflow history, and treat compaction as a recorded act whose output replaces the items. Replay returns the stored shorter list and leaves the shortening step idle. A length error becomes a branch in the workflow: run the shortening activity, then call the model with the new list. The Codex failure, where every follow-up meets the same overflow, is answered by a stored shorter list, produced by an activity that finished, sitting in the history.

For the sandbox, take a snapshot between commands, when the project is quiet. A snapshot taken while the tests are writing a file freezes the half-written file. The shell activity's call id is the repeat label. The call id is the identifier of that one tool request, and it stays the same if the step is tried again. On a retry, the room looks up whether that call id already has a result, and a stored result is what comes back. When the history has an opening for that call id, the command runs. If the room itself is gone, an activity creates a new room from the last quiet snapshot, and the command runs there under the same call id.

For the model call, retry the errors that belong to the moment: too many requests, an overload, a time limit, a connection that closed early. Record the successful reply, and let replay return it. A length error is a property of this prompt, so the workflow changes the prompt and then calls again. Long steps send a check-in while they run. A model call that streams for minutes, or a compile that runs for ten, sends a short "still working" note every few seconds. When those notes stop, the platform treats the activity as failed and can run it on another worker. The call id keeps the second worker from starting a second compile that fights the first. You stop the old command if the room is still up, and you trust the call id if the room is being replaced.

For approvals and for your next message, the workflow waits on a signal. It reaches "this shell needs a person" and waits. You approve it the next morning. The worker that receives the signal may be a different process from the one that started the wait. The command runs after the signal, and the history shows the wait and the decision.

Large logs need a size rule. Activity results are stored in the history. A huge test log, stored in full, makes the history heavy and makes replay heavier. The activity returns the exit code, the ending of the log, and a path. The full log stays in a file in the sandbox, and a later tool call can read that file. Cursor has described a similar shift for their own agents: write the large output to a file the agent can search, and keep the message that wakes the agent small.

## Temporal keeps the loop as a workflow and every outside change as an activity

Temporal offers the log, the replay, the timers, the signals, and the workers. For agents, the public connection to OpenAI's agent toolkit makes the mapping specific. That toolkit is a library for writing the loop in ordinary code.

The loop's decisions run inside the workflow. Each model call runs as an activity, so a finished call is stored and is returned on replay, and a failed call is retried under a policy you set. A time limit, a limit on how long the step may go quiet, and a retry policy are settings of that activity. Tools that reach outside the workflow, such as a web request or a shell, run as activities too. A tool that is pure calculation, the same answer every time from the same input, can run inside the workflow, because replay will compute the same value again.

For an agent that has a sandbox, the integration runs every sandbox operation as its own activity: creating the session, each command, each read and write, an interactive terminal, and shutting the room down. The session state is written into the workflow, so a worker restart in the middle of a run continues against the same session. Their sample workflow receives a user message, runs a turn that may include many commands, and then waits for the next message. The wait survives the worker, and the workflow remains in the service while every worker is busy elsewhere.

One detail in that integration is the placement from the first part of this essay, showing up as a sharp edge. Their local sandbox option runs commands on the worker's own machine and copies the worker's environment into the command, which includes the model key. Temporal's guide limits that option to local experiments with prompts you trust, and it tells you to point production at a remote sandbox, such as a container or a hosted room. The workflow code stays the same. The worker's settings are what point the activities at a room that holds the project and leaves the model key on the worker. Command output still comes back as an activity result and lands in the history, which is why the size rule for logs matters even more once the room is remote.

Taken together, a workflow is the session, activities are the model call and the commands and the snapshots, and signals are you, talking again or approving a command. The history is the record that outlives the worker and the room.

<figure>
  <img src="/assets/images/durable-codex-session.svg" alt="A workflow holding the thread, a sandbox handle, and a snapshot id, with activities for the model call, the shell, and the snapshot, above a separate sandbox machine.">
  <figcaption>The Codex session is a workflow that remembers the thread, the live sandbox, and a snapshot of the files. Calling the model, running a command, and taking the snapshot are separate recorded steps, so a worker crash continues from the step that is still open.</figcaption>
</figure>

## A Codex session becomes durable when each model call and each command is a recorded step

Codex's loop, as OpenAI describes it, is already the sequence you would write down. The harness builds a list of input items. One of those items is a note, written in the role of instructions from the program's authors, that describes the sandbox, and that description applies to the shell tool. The project instructions and your message follow. The harness calls the Responses API, which is the web service Codex uses to ask the model for the next reply. The model returns a message for you, or it returns a tool call. For the shell tool, Codex runs the command inside the sandbox and appends the output. The cycle repeats until a message for you ends the turn. When the list grows past the context window, a compaction call returns a shorter list, and that list becomes the input. On your laptop, Codex stores the thread and can resume it on the same machine. The durable version is this same sequence with the log outside the process and outside the room.

Here is a path you can build against that loop. The example is still the login-form test.

Give the session a workflow id, the same id you would have used for the Codex thread. The worker process holds the model key in its environment. The sandbox is a remote container or a small virtual machine. Creating it is an activity, which you can name `ensure_sandbox`. Its inputs are the project and either a handle for a live room or a snapshot id. The activity returns a handle, and replay returns that same handle once this activity has finished.

The workflow's memory starts as the input list: the note that describes the sandbox, the instructions, and your sentence about the empty password, and that list is the thread.

Call the model in an activity, `call_model`, with the current list. The retry policy tries again after too many requests, an overload, a time limit, and a connection that closed early. Each retry is a new draft, and the history keeps the draft that returned a complete reply. A length error comes back to the workflow as a result the workflow can branch on. The workflow then runs `compact`, an activity that asks the model service to shorten the thread, or that runs a local summary if you have written one. The result is the shorter list. The workflow replaces its thread with that list and calls the model again. Because the shorter list is an activity result, a crash during the following model call replays straight to `call_model` with the short list already in hand. A thread with a stored recovery continues, and a thread whose shortening step failed and was retried unchanged stays stuck.

When the reply contains a shell tool call, run an activity named `run_shell` with the sandbox handle, the command, and the tool call id. Inside the room, a small wrapper looks up the call id. A stored result for that id is returned at once. When the history has an opening for that id, the command runs. While the tests run, the activity sends a short check-in every few seconds, so Temporal can tell a live step from a dead one. The result that goes into the history is the exit code, the ending of the output, and the path of the full log in the room. The workflow appends the tool call and this result to the thread, and it goes back to `call_model`.

When `run_shell` fails because the room is gone, the workflow calls `ensure_sandbox` with the last snapshot id. That activity starts a new room from the quiet snapshot and returns a new handle. `run_shell` runs again under the same call id. If the previous attempt had stored a result before the room died, replay already has that result and moves past `run_shell`. The risky window is the one where the tests died halfway through a write and left the history with an opening for that call id. The quiet snapshot is from before that command, so running the command again on the new room repeats a command that may have been partial on a machine you have since deleted. You accept that repeat, because the partial machine is gone and the call id on the new room starts clean. You keep two rooms from applying one command by creating the replacement only when the history has an opening for that call id.

If the command needs your approval, the workflow waits for a signal, `approve` or `deny`, before `run_shell`. The wait survives a closed laptop. In the morning the signal arrives, a worker resumes the workflow, and the command runs. A denial appends a tool error the model can read, and `call_model` runs with that error in the thread.

A message for you ends the turn. The workflow runs `snapshot` and stores the new snapshot id. Then it waits for a signal, `user_message`. You send "also cover a password that is only spaces." The signal is recorded, the workflow appends it to the thread, and the loop continues. Closing the browser tab leaves this wait in place, because the wait lives in the Temporal service.

A worker can exit at any line above. The next worker replays, finished activities return their recorded results, and the activity that is still open runs, so you still see one session.

Two practical details keep the path honest. When the history has grown because the session has lasted for days, you start a fresh record that carries the current thread, the sandbox handle, and the snapshot id. The new workflow continues the session, and the old history is complete and can be stored away. And the model key stays on the worker. The sandbox activity receives the project and the test secrets. This is the outside placement from the beginning of the essay, and it is what makes a replaced sandbox an ordinary cost: the key that calls the model was on the worker the whole time, and the transcript was in the history.

A smaller experiment makes the idea tangible on one computer. Run Codex on the login-form project, let it take a few tool calls, stop the process, and resume the stored thread. You will see the session survive the process, on one disk. The steps above are what you add so the same resume still works when that disk and the sandbox are both gone. Temporal's connection to OpenAI's agent toolkit is the published version of those steps for that toolkit: model calls and sandbox operations are activities, and the session state is written onto the workflow. A Codex session is the same shape, pointed at the Responses API and at the shell tool Codex already places in a sandbox.

The placement and the durability path are one choice. The harness runs outside the sandbox, so the record of the session can live with the harness, in a log that replay can trust, while the tools run inside a room you are free to throw away and rebuild from a snapshot. You can count on the transcript, the next step, and the model key surviving a sandbox that has been replaced. You pay for the trip across the boundary, for the snapshots, and for a repeat label on every command that changes the project. That price is what keeps the login-form task the same task in the morning.
