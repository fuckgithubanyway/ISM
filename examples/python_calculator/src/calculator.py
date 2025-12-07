def add(a: float, b: float) -> float:
    """Add two numbers.
    
    Args:
        a (float): First operand
        b (float): Second operand
    
    Returns:
        float: Sum of a and b
    """
    return a + b


def subtract(a: float, b: float) -> float:
    """Subtract one number from another.
    
    Args:
        a (float): Minuend
        b (float): Subtrahend
    
    Returns:
        float: Difference between a and b
    """
    return a - b


def multiply(a: float, b: float) -> float:
    """Multiply two numbers.
    
    Args:
        a (float): First multiplicand
        b (float): Second multiplicand
    
    Returns:
        float: Product of a and b
    """
    return a * b


def divide(a: float, b: float) -> float:
    """Divide one number by another.
    
    Args:
        a (float): Dividend
        b (float): Divisor
    
    Returns:
        float: Quotient of a divided by b
    
    Raises:
        ValueError: If divisor b is zero
    """
    if b == 0.0:
        raise ValueError("Division by zero is not allowed.")
    return a / b
