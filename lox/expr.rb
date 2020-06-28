class Expr
    class Visitor
        def visit_binary_expr(expr)
        end
        def visit_grouping_expr(expr)
        end
        def visit_literal_expr(expr)
        end
        def visit_unary_expr(expr)
        end
    end
    class Binary < Expr
        attr_reader :left, :operator, :right
        def initialize(left, operator, right)
            @left = left
            @operator = operator
            @right = right
        end
        def accept(visitor)
            return visitor.visit_binary_expr(self)
        end
    end
    class Grouping < Expr
        attr_reader :expression
        def initialize(expression)
            @expression = expression
        end
        def accept(visitor)
            return visitor.visit_grouping_expr(self)
        end
    end
    class Literal < Expr
        attr_reader :value
        def initialize(value)
            @value = value
        end
        def accept(visitor)
            return visitor.visit_literal_expr(self)
        end
    end
    class Unary < Expr
        attr_reader :operator, :right
        def initialize(operator, right)
            @operator = operator
            @right = right
        end
        def accept(visitor)
            return visitor.visit_unary_expr(self)
        end
    end
    def accept(visitor)
    end
end
