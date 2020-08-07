MIA Input Tracker Todo List (Not in any particular order of importance)

- remove scroll glow
- Code refactoring
    - Use themes (and dark mode)
- Reduce number of Firebase reads
    - Add field that contains total input in a day for each category
- Statistics page
    - add page indicator
    - streaks for meeting daily goals
    - Lifetime summaries
- Add page
    - User should be able to tap category to add an entry directly without having to select in the add screen
    - Sliders kinda suck, there should be something else that's faster and more comfortable
- Goal page
    - Current goals should be displayed rather than just an empty text field
    - Instead of direct text input, a time picker should be used for time goals and number input for quantity goals
- Settings Page
    - Allow user to choose between keeping or deleting log data when removing a category
    - Allow user to give each category a color (for graphs and other widgets)
- First time user landing page
   
- Figure out how to optimize code (Adding any more features causes noticeable lag)



- Finish transitioning data model
    - Category and current goal data should be stored directly in the user document, finish changing the code to fit that
    - Switch most usages of FirebaseUser to AppUser
  
