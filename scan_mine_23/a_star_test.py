import tkinter, time, random


width, height = 420, 420
cell_size, border = 20, 1

root = tkinter.Tk()

canvas = tkinter.Canvas(root, bg="#000", highlightthickness=0, height=height, width=width)

class Node:
    CLOSED = 0
    UNVISITED = 1
    OPEN = 2

    EMPTY = 0
    OBSTACLE = 1
    TARGET = 2

    def __init__(self, x, y, node_type=0, status=1, direction=0) -> None:

        self.x = x
        self.y = y

        self.status = status
        self.type = node_type
        self.direction = direction

        self.previous_node = None
        self.cost_so_far = -1
        self.total_cost = -1
        self.heuristic_cost = -1
    
    pos = property(lambda self: (self.x, self.y))

class Turtle:
    directions = {
        0: (0, -1),
        1: (1, 0),
        2: (0, 1),
        3: (-1, 0)
    }
    def __init__(self, pos, direction) -> None:
        self.x = pos[0]
        self.y = pos[1]
        self.dir = direction
    
    def forward(self):
        x, y = Turtle.directions[self.dir]
        self.x += x
        self.y += y

    def turnLeft(self):
        self.dir = (new_dir := self.dir - 1) + (new_dir < 0) * 4

    def turnRight(self):
        self.dir = (self.dir + 1) % 4
    
    def drawTurtle(self, canvas):
        canvas.create_rectangle(
            self.x * cell_size,
            self.y * cell_size,
            (self.x + 1) * cell_size,
            (self.y + 1) * cell_size,
            fill="#000000"
        )
        canvas.create_rectangle(
            self.x * cell_size + border,
            self.y * cell_size + border,
            (self.x + 1) * cell_size - border,
            (self.y + 1) * cell_size - border,
            fill="#323232"
        )
        ax, ay = Turtle.directions[self.dir]
        canvas.create_line(
            (center_x := (self.x + 0.5) * cell_size), 
            (center_y := (self.y + 0.5) * cell_size),
            center_x + ax * cell_size,
            center_y + ay * cell_size
        )

    pos = property(lambda self: (self.x, self.y))

def heuristic(start_pos, end_pos):
    return abs(end_pos[0] - start_pos[0]) + abs(end_pos[1] - end_pos[0])

def a_star(obstacles, start_pos, end_pos):
    node_map: list[Node] = [[Node(x, y) for x in range(0, width // cell_size)] for y in range(0, height // cell_size)]
    
    # Marking Obstacles
    for x, y in obstacles:
        node_map[y][x].type = Node.OBSTACLE
    
    # Marking Start
    start_node = node_map[start_pos[1]][start_pos[0]]
    start_node.status = Node.OPEN
    start_node.total_cost = heuristic(start_pos, end_pos)

    # Marking End
    end_node = node_map[end_pos[1]][end_pos[0]]
    end_node.type = Node.TARGET

    directions = {
        0: (0, -1),
        1: (1, 0),
        2: (0, 1),
        3: (-1, 0)
    }
    for key, value in list(directions.items()):
        directions[value] = key

    def get_smallest():
        current: Node = None
        for row in node_map:
            for node in row:
                if node.status == Node.OPEN:  # Check if the node is open
                    if not current:
                        current = node
                    elif node.total_cost < current.total_cost:
                        current = node
        return current

    def neighbors(current_node):

        return [
            (current_node.x + 1, current_node.y),
            (current_node.x - 1, current_node.y),
            (current_node.x, current_node.y + 1),
            (current_node.x, current_node.y - 1)
        ]

    while (current := get_smallest()):
        if current.type == Node.TARGET:
            break
        
        current.status = Node.CLOSED

        for x, y in neighbors(current):
            if not (0 <= x < width // cell_size and 0 <= y < height // cell_size):
                continue
            node = node_map[y][x]
            if node.type == Node.OBSTACLE:
                continue
            direction_to_node = directions[(node.x - current.x, node.y - current.y)]
            
            next_cost = current.cost_so_far + 1 + (direction_to_node - current.direction) % 3  # The cost of rotating in that direction

            if node.status == Node.UNVISITED:
                node.previous_node = current
                node.direction = direction_to_node
                
                node.heuristic_cost = heuristic(node.pos, end_node.pos) # Update its heuristic_cost
                node.cost_so_far = next_cost                            # Update the cost_so_far
                node.total_cost = next_cost + node.heuristic_cost       # Update total_cost
                node.status = Node.OPEN                                 # Open node

            elif node.status == Node.OPEN or node.status == Node.CLOSED:
                if next_cost <= node.cost_so_far:
                    node.previous_node = current                        # Update the previous_node
                    node.direction = direction_to_node
                    node.status = Node.OPEN                             # Re-open node
                    node.cost_so_far = next_cost                        # Fix its cost_so_far
                    node.total_cost = next_cost + node.heuristic_cost   # Fix total_cost

    if end_node.previous_node:  # We successfully reached the end node!
        path: list[Node] = [end_node]
        while path[-1] != start_node:
            path.append(path[-1].previous_node)

        print("Length:", len(path))
        return list(reversed(path)), path[0].total_cost
    
    return [], None
    # for column in node_map:
    #     for node in column:
    #         print(node.type, end=" ")
    #     print()


def load_map() -> tuple[list[tuple], tuple, tuple]:

    file = open("scan_mine_23/map.txt", "r")
    obstacles, start_pos, end_pos = [], None, None

    for y, line in enumerate(file.readlines()):
        line = line.strip()
        for x, char in enumerate(line):
            if char == "1":
                obstacles.append((x, y))
            elif char == "2":
                start_pos = (x, y)
            elif char == "3":
                end_pos = (x, y)

    return obstacles, start_pos, end_pos
        

def main():
    running = True
    ran_pos = lambda: (random.randint(0, width // cell_size - 1), random.randint(0, height // cell_size - 1))

    obstacles = []

    obstacles, start_pos, target_pos = load_map()
    # for _ in range(30):
    #     while (new_obstacle := ran_pos()) in obstacles:
    #         ...
    #     obstacles.append(new_obstacle)

    while (turtle_pos := ran_pos()) in obstacles:
        ...
    x_pos, y_pos = turtle_pos
    # start_pos = (x_pos, y_pos)
    # direction = random.randint(0, 3)

    # while (target_pos := ran_pos()) in obstacles:
    #     ...
    path, cost = a_star(obstacles, start_pos, target_pos)

    for node in path:
        print(node.pos, node.direction)

    turtle, path_index = Turtle(start_pos, 0), 1

    while running:
        

        # Ticking
        if turtle.dir != (new_dir := path[path_index].direction):
            turtle.dir = new_dir
            time.sleep(0.25)
        else:
            turtle.forward()
            path_index += 1
            time.sleep(0.125)

        # Drawing
        canvas.create_rectangle(0, 0, width, height, fill="#000")
        
        for x in range(0, width, 20):
            for y in range(0, height, 20):
                canvas.create_rectangle(
                    x + border + border,
                    y + border + border,
                    x + cell_size - border,
                    y + cell_size - border,
                    fill="#323232"
                )

        for x, y in obstacles:
            canvas.create_rectangle(
                x * cell_size + border,
                y * cell_size + border,
                (x + 1) * cell_size - border,
                (y + 1) * cell_size - border,
                fill="#ff0000"
            )

        for node in path:
            x, y = node.pos
            canvas.create_rectangle(
                x * cell_size + 5 * border,
                y * cell_size + 5 * border,
                (x + 1) * cell_size - 5 * border,
                (y + 1) * cell_size - 5 * border,
                fill="#00ff00"
            )
        x, y = target_pos
        canvas.create_rectangle(
            x * cell_size + border,
            y * cell_size + border,
            (x + 1) * cell_size - border,
            (y + 1) * cell_size - border,
            fill="#ffff00"
        )
        x, y = start_pos
        canvas.create_rectangle(
            x * cell_size + border,
            y * cell_size + border,
            (x + 1) * cell_size - border,
            (y + 1) * cell_size - border,
            fill="#ffaa00"
        )
        turtle.drawTurtle(canvas)
                
        canvas.pack()
        root.update()


main()
