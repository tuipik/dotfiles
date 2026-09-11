local M = {}

function M:spot(job)
	local rows = require("file"):spot_base(job)

	table.insert(rows, 4, ui.Row {
		"  Size:",
		ya.readable_size(job.file.cha.len),
	})

	ya.spot_table(
		job,
		ui.Table(rows)
			:area(ui.Pos { "center", w = 60, h = 20 })
			:row(1)
			:col(1)
			:col_style(th.spot.tbl_col)
			:cell_style(th.spot.tbl_cell)
			:widths {
				ui.Constraint.Length(14),
				ui.Constraint.Fill(1),
			}
	)
end

return M
