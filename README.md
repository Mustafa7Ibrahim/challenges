

# Challenges Report

This document highlights the challenges encountered during the development process and the solutions implemented to overcome them.

---

## Challenge 1:

### Issues and Solutions

1. **Timer Not Canceling on Widget Disposal**  
   - **Issue**: The timer continued running after the widget was disposed, leading to potential memory leaks.  
   - **Solution**: Added `timer.cancel();` in the widget's `dispose` method to ensure proper cleanup.

2. **Unnecessary Rebuilds of the Entire Screen**  
   - **Issue**: Updating the `counter` caused the entire screen to rebuild, affecting performance.  
   - **Solution**: Separated the animation section from the main screen to reduce unnecessary rebuilds.

3. **Inefficient Rendering of 1000 Items at Once**  
   - **Issue**: Rendering all 1000 items at once using `ListView` caused performance bottlenecks.  
   - **Solution**: Replaced `ListView` with `SliverList.builder` to load items on demand.

4. **Reloading All Items on Screen Rebuild**  
   - **Issue**: The entire list of 1000 items reloaded every time the screen was rebuilt.  
   - **Solution**: Implemented pagination to load items incrementally, reducing reload times.

5. **Animation Section Re-rendering with the List**  
   - **Issue**: The animation section re-rendered unnecessarily when the list was updated.  
   - **Solution**: Separated the animation and list sections into distinct widgets to prevent redundant re-renders.

---

## Challenge 2:

### Issues and Solutions

1. **Generating 50,000 Items at Startup**  
   - **Issue**: Generating all 50,000 items at once at the start caused delays and high memory usage.  
   - **Solution**: Combined `SliverList.builder` with pagination to load items dynamically as needed.

2. **Heavy Work on the Main Thread**  
   - **Issue**: Filtering and sorting operations were performed on the main thread, causing UI freezes.  
   - **Solution**: Moved these operations to a separate isolate using `isolate.run()` to offload the work and keep the main thread responsive.