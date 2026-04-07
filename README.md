# LevelHub UI Library

## Quick Start Guide

To get started with the LevelHub UI Library, follow these simple steps:
1. Install the library using npm:
   ```bash
   npm install levelhub-ui-lib
   ```
 
2. Import the components into your project:
   ```javascript
   import { Button, Modal } from 'levelhub-ui-lib';
   ```

3. Use the components in your JSX:
   ```jsx
   <Button onClick={handleClick}>Click Me!</Button>
   ```

## Components Guide

### Button
- **Props:**
  - `onClick`: Function to handle the click event.
  - `label`: Text to display on the button.
- **Example:**
  ```jsx
  <Button label="Submit" onClick={submitHandler} />
  ```

### Modal
- **Props:**
  - `isOpen`: Boolean to control visibility.
  - `onClose`: Function called when modal is closed.
- **Example:**
  ```jsx
  <Modal isOpen={isOpen} onClose={handleClose}>Content here</Modal>
  ```

## Examples

### Example 1: Basic Button
```jsx
<Button onClick={() => alert('Button Clicked!')}>Click Me!</Button>
```

### Example 2: Using Modal
```jsx
function App() {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <>
      <Button onClick={() => setIsOpen(true)}>Open Modal</Button>
      <Modal isOpen={isOpen} onClose={() => setIsOpen(false)}>
        <h2>Hello!</h2>
        <p>This is a modal.</p>
      </Modal>
    </>
  );
}
```

## Troubleshooting

- **Issue:** Components are not rendering.
  - **Solution:** Ensure you have properly imported the components and that there are no JavaScript errors in the console.

- **Issue:** Modal is not opening.
  - **Solution:** Check if the `isOpen` prop is set to `true` and that the `onClose` function is correctly defined.

If you encounter any other issues, refer to the documentation or raise an issue in the repository.