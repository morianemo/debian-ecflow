all:
	jupyter notebook ecFlow.ipynb
cli:
	jupyter nbconvert --to script ecFlow.ipynb
pdf:
	jupyter nbconvert --to pdf ecFlow.ipynb
slides:
	jupyter nbconvert --to slides ecFlow.ipynb
docker:
	docker run --rm -it -p 8888:8888 -v "$(pwd):/notebooks" jupyter/notebook 
tex:
	jupyter nbconvert --to latex ecFlow.ipynb 
test:
	# convert test.gif -coalesce +repage -background none ( -clone 0--1 -trim -flatten -trim ) -set option:distort:viewport %[fx:u[-1].w]x%[fx:u[-1].h]+%[fx:u[-1].page.x]+%[fx:u[-1].page.y] -distort SRT 0 +repage -delete -1 tmp.gif
	# magick test.gif -coalesce +repage ( -clone 0--1 -transparent %[pixel:p{0,0}] -flatten -trim ) -crop %[fx:u[-1].w]x%[fx:u[-1].h]+%[fx:u[-1].page.x]+%[fx:u[-1].page.y] +repage -delete -1 tmp.gif

convert:
	convert anim/ecflow.gif -coalesce ecflow.png && \rm ecflow-?.png
	# bgcolor=$(convert input.gif[0] -format "%[pixel:u.p{0,0}]" info:); convert -dispose previous -delay 10 -background "$bgcolor" input.gif -trim -layers TrimBounds -coalesce -layers optimize -loop 0 output.gif
	convert anim/ecflow_el.gif ecflow_el.png && \rm ecflow_el-1*.png ecflow_el-[2-9].png
	convert anim/ecflow_status.gif ecflow_status.png && \rm ecflow_status-?.png ecflow_status-[12]?.png

# pip3 install jupyter_contrib_nbextensions
clean:
	\rm *~ *.def.log *.depth *.flat
