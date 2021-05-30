require "kemal"
require "celestine"
require "math"
require "random"

WIDTH = 400
HEIGHT = 400

LINE_X_SCALE = 4
LINE_X_INTERVAL = WIDTH / 20
LINE_X_OFFSET = (WIDTH * LINE_X_SCALE - WIDTH) / 2
LINE_INTERVAL_Y = 8
LINE_STROKE = "#40f9ff"

SUN_COLORS = [
    "#5ebd3e",
    "#ffb900",
    "#f78200",
    "#e23838",
    "#973999",
    "#009cdf"
]
SUN_X = WIDTH / 2
SUN_Y = HEIGHT / 2 - 100
SUN_RADIUS = 60
SUN_STRIPE_INTERVAL = (1 / SUN_COLORS.size) * (SUN_RADIUS * 2)
SUN_MASK_FREQ = 3
SUN_MASK_BITMASK = 0b110

SKY_COLOR_A = "#000038"
SKY_COLOR_B = "#070757"
SKY_STARS = 300

SUN_BEAM_SIZE = 2
SUN_BEAM_GROUPS = 3
SUN_BEAM_Y = SUN_Y - (SUN_BEAM_GROUPS / 2) * (SUN_BEAM_SIZE * SUN_COLORS.size + SUN_COLORS.size)
SUN_BEAM_X = SUN_X - (SUN_BEAM_GROUPS / 2) * (SUN_BEAM_SIZE * SUN_COLORS.size + SUN_COLORS.size)
SUN_GAP = 10

MOUNTAIN_MIN_HEIGHT = 20
MOUNTAIN_MAX_HEIGHT = 30
MOUNTAIN_MIN_WIDTH = 20
MOUNTAIN_MAX_WIDTH = 60

TEXT_X = WIDTH / 2
TEXT_Y = HEIGHT / 2 + 50
TEXT_COLOR_A = "#003a97"
TEXT_COLOR_B = "#da39d7"

r = Random.new

get "/" do
    code = Celestine.draw do |ctx|
        ctx.width = WIDTH
        ctx.height = HEIGHT

        ctx.rectangle do |r|
            ctx.radial_gradient do |g|
                g.id = "sky-fill"

                stop_a = Celestine::Gradient::Stop.new
                stop_a.color = SKY_COLOR_A
                stop_a.offset = 0
                stop_a.offset_units = "%"

                stop_b = Celestine::Gradient::Stop.new
                stop_b.color = SKY_COLOR_B
                stop_b.offset = 100
                stop_b.offset_units = "%"

                g.start_x = 50
                g.start_y = 100
                g.x = 50
                g.y = 0
                g.x_units = g.y_units = g.start_x_units = g.start_y_units = "%"
                g.radius = g.start_radius = 50
                g.radius_units = g.start_radius_units = "%"

                g << stop_a
                g << stop_b

                g
            end

            r.x = 0
            r.y = 0
            r.width = WIDTH
            r.height = HEIGHT / 2

            r.fill = "url(#sky-fill)"

            r
        end

        ctx.mask do |m|
            m.id = "star-mask"

            m.rectangle do |r|
                r.x = 0
                r.y = 0
                r.width = WIDTH
                r.height = HEIGHT / 2

                r.fill = "white"

                r
            end

            m.rectangle do |r|
                r.x = 0
                r.y = SUN_BEAM_Y
                r.width = WIDTH
                r.height = SUN_BEAM_GROUPS * (SUN_BEAM_SIZE * SUN_COLORS.size + SUN_COLORS.size)
                
                r.fill = "black"

                r
            end

            m.rectangle do |r|
                r.x = SUN_BEAM_X
                r.y = 0
                r.width = SUN_BEAM_GROUPS * (SUN_BEAM_SIZE * SUN_COLORS.size + SUN_COLORS.size)
                r.height = HEIGHT / 2
                
                r.fill = "black"

                r
            end

            m.circle do |c|
                c.x = SUN_X
                c.y = SUN_Y
                c.radius = SUN_RADIUS + SUN_GAP

                c.fill = "white"

                c
            end

            m.circle do |c|
                c.x = SUN_X
                c.y = SUN_Y
                c.radius = SUN_RADIUS

                c.fill = "black"

                c
            end

            m
        end

        ctx.group do |g| 
            SKY_STARS.times do 
                    g.circle do |c|
                        c.radius = 0.5
                       
                        c.x = r.rand 0..WIDTH
                        c.y = r.rand 0..(HEIGHT // 2)

                        c.stroke = "white"

                        c
                    end

            end
            g.set_mask "star-mask"

            g
        end

        ctx.group do |g|

            ctx.mask do |m|
                m.id = "beam-mask"

                m.rectangle do |r|
                    r.x = 0
                    r.y = SUN_BEAM_Y
                    r.width = WIDTH
                    r.height = SUN_BEAM_GROUPS * (SUN_BEAM_SIZE * SUN_COLORS.size + SUN_COLORS.size)
                    
                    r.fill = "white"

                    r
                end

                m.rectangle do |r|
                    r.x = SUN_BEAM_X
                    r.y = 0
                    r.width = SUN_BEAM_GROUPS * (SUN_BEAM_SIZE * SUN_COLORS.size + SUN_COLORS.size)
                    r.height = HEIGHT / 2
                    
                    r.fill = "white"

                    r
                end

                m.circle do |c|
                    c.x = SUN_X
                    c.y = SUN_Y
                    c.radius = SUN_RADIUS + SUN_GAP
    
                    c.fill = "black"
    
                    c
                end

                m
            end

            beam_x = SUN_BEAM_X
            beam_y = SUN_BEAM_Y

            SUN_BEAM_GROUPS.times do
                SUN_COLORS.each do |color|
                    SUN_BEAM_SIZE.times do |n|
                        g.path do |p|
                            p.a_move 0, beam_y + n
                            p.r_h_line WIDTH
                            p.stroke = color

                            p 
                        end

                        g.path do |p|
                            p.a_move beam_x + n, 0
                            p.r_v_line HEIGHT / 2
                            p.stroke = color

                            p 
                        end
                    end

                    beam_y += SUN_BEAM_SIZE + 1
                    beam_x += SUN_BEAM_SIZE + 1
                end
            end

            g.set_mask "beam-mask"

            g
        end

        ctx.circle do |c|
            c.x = SUN_X
            c.y = SUN_Y
            c.radius = SUN_RADIUS

            ctx.pattern do |p|
                p.id = "sun-fill"

                SUN_COLORS.each_with_index do |color, n|
                    p.x = 0
                    p.y = 0
                    p.width = 1
                    p.height = 1

                    p.rectangle do |r|
                        r.x = 0
                        r.y = n / SUN_COLORS.size * (SUN_RADIUS * 2)
                        r.width = SUN_RADIUS * 2
                        r.height = SUN_STRIPE_INTERVAL

                        r.fill = color

                        r
                    end
                end

                p
            end

            ctx.mask do |m|
                m.id = "sun-mask"

                (SUN_COLORS.size + 1).times do |n|
                    n -= 1
                    base_y = SUN_Y - SUN_RADIUS + SUN_STRIPE_INTERVAL * n

                    SUN_MASK_FREQ.times do |f|
                        m.rectangle do |r|
                            r.x = SUN_X - SUN_RADIUS
                            r.y = base_y + (SUN_STRIPE_INTERVAL / SUN_MASK_FREQ) * f
                            r.width = SUN_RADIUS * 2
                            r.height = SUN_STRIPE_INTERVAL / SUN_MASK_FREQ + 1
                            r.fill = (SUN_MASK_BITMASK & (2 << f)) != 0 ? "white" : "black"

                            r.animate_motion do |a|
                                a.duration = 5
                                a.duration_units = "s"
                                a.repeat_count = "indefinite"

                                a.mpath do |p|
                                    p.a_move 0, 0  
                                    p.r_v_line SUN_STRIPE_INTERVAL

                                    p
                                end

                                a
                            end

                            r
                        end
                    end
                end

                m
            end

            c.fill = "url(#sun-fill)"
            c.set_mask "sun-mask"

            c
        end

        ctx.rectangle do |r|
            r.x = 0
            r.y = HEIGHT / 2
            r.width = WIDTH
            r.height = HEIGHT / 2

            r.fill = "black"

            r
        end

        ctx.path do |p|
            p.a_move 0, init_y = HEIGHT / 2 - MOUNTAIN_MIN_HEIGHT
            x = 0

            while x < WIDTH
                x += r.rand MOUNTAIN_MIN_WIDTH..MOUNTAIN_MAX_WIDTH
                p.a_line x, HEIGHT / 2 - r.rand(MOUNTAIN_MIN_HEIGHT..MOUNTAIN_MAX_HEIGHT)
            end

            p.a_line WIDTH, HEIGHT / 2
            p.a_line 0, HEIGHT / 2
            p.a_line 0, init_y
            p.close

            p.stroke = LINE_STROKE
            p.fill = "black"

            p
        end

        line_x = LINE_X_INTERVAL / 2
        line_off = -WIDTH / 2 * LINE_X_SCALE + LINE_X_INTERVAL
        while line_x < WIDTH
            ctx.path do |p|
                p.a_move line_x, HEIGHT / 2
                p.a_line line_x + line_off, HEIGHT

                p.stroke = LINE_STROKE

                p
            end

            line_x += LINE_X_INTERVAL
            line_off += LINE_X_INTERVAL * LINE_X_SCALE
        end 

        line_y = HEIGHT / 2# + LINE_INTERVAL_Y
        line_inc = LINE_INTERVAL_Y
        while line_y < HEIGHT
            ctx.path do |l|
                l.a_move 0, line_y
                l.r_h_line WIDTH
                l.stroke = LINE_STROKE

                l.animate_motion do |a|
                    a.duration = 1.3
                    a.duration_units = "s"
                    a.repeat_count = "indefinite"

                    a.mpath do |m|
                        m.a_move 0, 0
                        m.r_v_line line_inc

                        m
                    end

                    a
                end

                l
            end

            line_y += line_inc
            line_inc += 2
        end

        ctx.linear_gradient do |g|
            g.id = "text-fill-a"

            stop_a = Celestine::Gradient::Stop.new
            stop_a.color = "black"
            stop_a.offset = 0
            stop_a.offset_units = "%"

            stop_b = Celestine::Gradient::Stop.new
            stop_b.color = "blue"
            stop_b.offset = 50
            stop_b.offset_units = "%"

            stop_c = Celestine::Gradient::Stop.new
            stop_c.color = "white"
            stop_c.offset = 85
            stop_c.offset_units = "%"

            g.x1 = g.x2 = 0
            g.y2 = 100
            g.x1_units = g.x2_units = g.y1_units = g.y2_units = "%"

            g << stop_a
            g << stop_b
            g << stop_c

            g
        end

        ctx.linear_gradient do |g|
            g.id = "text-fill-b"

            stop_a = Celestine::Gradient::Stop.new
            stop_a.color = TEXT_COLOR_A
            stop_a.offset = 0
            stop_a.offset_units = "%"

            stop_b = Celestine::Gradient::Stop.new
            stop_b.color = TEXT_COLOR_B
            stop_b.offset = 50
            stop_b.offset_units = "%"

            stop_c = Celestine::Gradient::Stop.new
            stop_c.color = "white"
            stop_c.offset = 85
            stop_c.offset_units = "%"

            g.x1 = g.x2 = 0
            g.y2 = 100
            g.x1_units = g.x2_units = g.y1_units = g.y2_units = "%"

            g << stop_a
            g << stop_b
            g << stop_c

            g
        end

        ctx.pattern do |p|
            p.id = "text-fill"

            p.width = p.height = 1
            p.x = p.y = 0

            p.rectangle do |r|
                r.x = 0
                r.y = 0
                r.width = WIDTH
                r.height = 24
                r.fill = "url(#text-fill-a)"

                r
            end

            p.rectangle do |r|
                r.x = 0
                r.y = 24
                r.width = WIDTH
                r.height = 24
                r.fill = "url(#text-fill-b)"

                r
            end

            p
        end

        ctx.text do |t|
            t.font_family = "Rocket Rinder"
            t.font_size = 48
            t.text = "be gay"

            t.x = TEXT_X
            t.y = TEXT_Y
            t.stroke = "white"
            t.fill = "url(#text-fill)"
            t.custom_attrs["text-anchor"] = "middle"

            t
        end

        ctx.text do |t|
            t.font_family = "Rocket Rinder"
            t.font_size = 48
            t.text = "do crime"

            t.x = TEXT_X
            t.y = TEXT_Y + 50
            t.stroke = "white"
            t.fill = "url(#text-fill)"
            t.custom_attrs["text-anchor"] = "middle"

            t
        end
    end
    <<-EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>pride month vaporwave</title>
</head>
<body>
    #{code}
    <style>
        @font-face {
            font-family: "Rocket Rinder";
            src: url("rocket-rinder.ttf") format("truetype");
        }
    </style>
</body>
</html>
EOF
end

Kemal.run
