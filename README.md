# challenges

Here will be a report section for each challenge.

## Challenge 1
- issue (1):
    - Issue: the timer didn't canceled when the widget was disposed.
    - Solution: Adding a `timer.cancel();` in the `dispose` method.
- issue (2):
    - Issue: every time the `counter` did updated the whole screen was rebuild.
    - Solution: septate the animation section from the screen.
- issue (3):
    - Issue: Using ListView to render the whole 1000 items at once.
    - Solution: Using `SliverList.builder` to load the items on demand.
- issue (4):
    - Issue: whenever the screen rebuild it load all 1000 items again.
    - Solution: apply a `pagination` to load the items on demand.
- issue (5):
    - Issue: whenever list rerender it also rerender the animation section with it
    - Solution: septate the animation section and the list section in different widgets.

## Challenge 2
- issue (1):
    - Issue: generating the 50000 items at once at the start.
    - Solution: using a combination of `SliverList.builder` and `pagination` to load the items on demand.
- issue (2):
    - Issue: the `filter` and `sort` was did too much work on the main thread,
    - Solution: using `isolate.run()` to do the work on the isolate.
- 