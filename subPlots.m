classdef subPlots < handle
% TODO
% R labels messed up with resizing
% SUBPLOT SIZE
% CALCULATE FULL SIZE GIVEN:
%   subplot size
%   margin de
%   margin main
% y title shift given dimensions?
% x title shift given dimesions
% title shift given dimensions
% font placement
% y title closeness?
% r label not rotating
properties
    nRows
    nCols

    xticks
    yticks
    xtickLabels
    ytickLabels
   
    titl
    xtitl
    ytitl
    ctitl
    rtitl
    ititl

    clabelLoc
    rlabelLoc
    bRotateRlabel

    %OPTS

    % ticks
    bHideYticks
    bHideXticks
    xtickAngle
    ytickAngle
    xtickFormat
    ytickFormat

    %lims
    xlimRCBN% determine xlim by row,column,both,neither
    ylimRCBN % determin yliim by row,column,both,neither
    climRCBN
    ylim
    xlim
    clim
    ylimSpace
    xlimSpace
    bXlimsFromData
    bYlimsFromData
    bClimsFromData

    % labels
    bHideYlabel
    bHideXlabel

    %fonts
    fontsize
    fontsizeMain
    %[left bottom right top]
    %margin=[17 15 5 2];
    %
    %margin
    margin
    marginMain
    marginDE

    ax
    position
    bItitl% XXX ?

    xscale
    yscale
    bXsci
    bYsci

    bImg
end
properties(Hidden = true)
    yextent
    ytickextent
    sgt

    xdata
    ydata
    cdata
    xlimsMinMax
    ylimsMinMax
    climsMinMax
    xlimsall
    ylimsall
    climsall

    bYtitl
    bXtitl
    bTitl
    bCtitl
    bRtitl
    bRtitlEach
    ha
    RC

    top
    bottom
    left
    right
end
methods
    function obj = subPlots(RC,xtitl,ytitl,titl,rtitl,ctitl,Opts)
        % NOTE IF PROBLEM WITH GCF AXIS, REMOVE HOLD OFF
        if ~exist('Opts','var') || isempty(Opts)
            Opts=struct();
        end

        obj.nRows=RC(1);
        obj.nCols=RC(2);
        obj.RC=distribute(1:obj.nRows,1:obj.nCols);

        p=inputParser();
        p.addParameter('xtickFormat',[]);
        p.addParameter('ytickFormat',[]);
        p.addParameter('xtickAngle',0);
        p.addParameter('ytickAngle',0);
        p.addParameter('bYsci',[]);
        p.addParameter('bXsci',[]);
        p.addParameter('ylim',[]);
        p.addParameter('xlim',[]);
        p.addParameter('clim',[]);
        p.addParameter('ylimSpace',[]);
        p.addParameter('xlimSpace',[]);
        p.addParameter('xlimRCBN','C');
        p.addParameter('ylimRCBN','R');
        p.addParameter('climRCBN','N');
        p.addParameter('bYlimsFromData',0);
        p.addParameter('bXlimsFromData',0);
        p.addParameter('bClimsFromData',0);
        p.addParameter('xticks',[]);
        p.addParameter('yticks',[]);
        p.addParameter('xtickLabels',[]);
        p.addParameter('ytickLabels',[]);
        p.addParameter('bHideXticks',[]);
        p.addParameter('bHideYticks',[]);
        p.addParameter('bHideXlabel',1);
        p.addParameter('bHideYlabel',1);
        p.addParameter('ax','manual');
        p.addParameter('fontsize',18);
        p.addParameter('fontsizeMain',25);
        p.addParameter('margin',[]);
        p.addParameter('marginMain',[]);
        p.addParameter('marginDE',[]);
        p.addParameter('clabelLoc','top');
        p.addParameter('rlabelLoc',[]);
        p.addParameter('bRotateRlabel',[]);
        p.addParameter('position',[]);
        p.addParameter('xscale',[]);
        p.addParameter('yscale',[]);
        p.addParameter('bImg',0);

        p=parseStruct(Opts,p);
        flds=fieldnames(p.Results);
        for i = 1:length(flds)
            fld=flds{i};
            obj.(fld)=p.Results.(fld);
        end

        %%-----------------------------
        %% DEFAULTS
        if isempty(obj.rlabelLoc) && isempty(obj.bRotateRlabel)
            obj.rlabelLoc='right';
            obj.bRotateRlabel=1;
        elseif ~isempty(obj.rlabelLoc) && isempty(obj.bRotateRlabel)
            obj.bRotateRlabel=0;
        end

        %% HIDE TICKS
        if strcmp(obj.ylimRCBN,'R') && isempty(obj.bHideYticks)
            obj.bHideYticks=1;
        elseif isempty(obj.bHideYticks) && obj.bImg
            obj.bHideXticks=1;
        elseif isempty(obj.bHideYticks)
            obj.bHideYticks=0;
        end
        if strcmp(obj.xlimRCBN,'C') && isempty(obj.bHideXticks)
            obj.bHideXticks=1;
        elseif isempty(obj.bHideXticks) && obj.bImg
            obj.bHideXticks=1;
        elseif isempty(obj.bHideXticks)
            obj.bHideXticks=0;
        end

        if ~isempty(obj.xlim)
            obj.xlimRCBN='N';
        end
        if ~isempty(obj.ylim)
            obj.ylimRCBN='N';
        end

        if isempty(obj.yticks) && strcmp(obj.yscale,'log')
            obj.yticks=[.3 1 3 10];
        end

        % XXX
        if isempty(obj.position)
            obj.position(1)=3;
            obj.position(2)=3;
            obj.position(3)=RC(2)*300+200;
            obj.position(4)=RC(1)*300+200;
        end

        obj.bTitl=0;
        if exist('titl','var') && ~isempty(titl)
            obj.titl=titl;
            obj.bTitl=1;
        end
        % BOTTOM
        %
        obj.bXtitl=0;
        if exist('xtitl','var') && ~isempty(xtitl)
            obj.xtitl=xtitl;
            obj.bXtitl=1;
        end
        %% LEFT
        obj.bYtitl=0;
        if exist('ytitl','var') && ~isempty(ytitl)
            obj.ytitl=ytitl;
            obj.bYtitl=1;
        end
        obj.bCtitl=exist('ctitl','var') && iscell(ctitl) && any(size(ctitl)==obj.nCols) && any(any(cellfun(@(x) ~isempty(x),ctitl)));
        obj.bRtitl=exist('rtitl','var') && iscell(rtitl) && any(size(rtitl)==obj.nRows) && any(any(cellfun(@(x) ~isempty(x),rtitl)));
        obj.bItitl=exist('ititl','var') && iscell(ititl) && isequal(size(ititl),[obj.nRows obj.nCols]) && any(cellfun(@(x) ~isempty(x),ititl));

        obj.bRtitlEach=0;
        if obj.bRtitl && isequal(size(rtitl),[obj.nCols obj.nRows])
            obj.bRtitlEach=1;
        end

        if obj.bCtitl
            obj.ctitl=ctitl;
        end
        if obj.bRtitl
            obj.rtitl=rtitl;
        end
        if obj.bItitl
            obj.ititl=ititl;
        end

        obj.ha=panel();
        obj.ha.pack('h',1);

        r=num2cell(repmat(1/obj.nRows,1,obj.nRows));
        c=num2cell(repmat(1/obj.nCols,1,obj.nCols));
        obj.ha(1).pack(r,c);

        warning('off','panel:PanelZeroSize');

        obj.get_margin();
        obj.get_main_margin();
        obj.init_margin();
        obj.ha.select('all');

        if strcmp(obj.yscale,'log') && isempty(obj.bYsci)
            obj.bYsci=1;
        end
        if strcmp(obj.xscale,'log') && isempty(obj.bXsci)
            obj.bXsci=1;
        end
        obj.get_xtickLabels();
        obj.get_ytickLabels();
    end
    function obj=init_margin(obj)
        %obj.ha.select('all');
        obj.ha.fontsize=obj.fontsizeMain;
        obj.ha.margin=obj.marginMain;
        obj.ha(1).de.margin=obj.marginDE;
        obj.ha(1,1).de.fontsize=obj.fontsize;
        %obj.ha(1).margintop=80;
    end
    function obj=get_margin(obj)
        if isempty(obj.marginDE)
            obj.marginDE=6;
        end
        %if obj.bHideXticks
        %    obj.margin(2)=10;
        %end
        %if obj.bHideYticks
        %    obj.margin(1)=10;
        %end
    end
    function obj=get_main_margin(obj)
        % Left bottom right top
        if isempty(obj.marginMain)
            obj.marginMain=[35 25 18 21.5];
        end
        obj.marginMain(2)=obj.marginMain(2)+ceil(obj.xtickAngle/30).*8;
        %obj.marginMain(2)=obj.marginMain(2)+mod(obj.xtickAngle,90)*obj.marginMain(2)./50
        return


        % TOP
        obj.top=0;
        if strcmp(obj.clabelLoc,'top') && obj.bCtitl && obj.bTitl
            obj.top=3;
            obj.marginMain(4)=(obj.fontsizeMain+obj.fontsize)/2; %30
        elseif (~obj.bCtitl || ~strcmp(obj.clabelLoc,'top')) && obj.bTitl
            obj.top=2;
            obj.marginMain(4)=obj.fontsizeMain; %30
        elseif strcmp(obj.clabelLoc,'top') && obj.bCtitl && ~obj.bTitl
            obj.top=1;
            obj.marginMain(4)=obj.fontsize;
        end

        % BOTTOM
        obj.bottom=0;
        if strcmp(obj.clabelLoc,'bottom') && obj.bCtitl && obj.bXtitl
            obj.bottom=3;
            obj.marginMain(2)=obj.fontsize+obj.fontsizeMain; %T
        elseif (~obj.bCtitl || ~strcmp(obj.clabelLoc,'bottom')) && obj.bXtitl
            obj.bottom=2;
            obj.marginMain(2)=obj.fontsizeMain; %T
        elseif strcmp(obj.clabelLoc,'bottom') && obj.bCtitl && ~obj.bXtitl
            obj.bottom=1;
            obj.marginMain(2)=obj.fontsize;
        end

        %% LEFT % 35
        obj.left=0;
        if strcmp(obj.rlabelLoc,'left') && obj.bRtitl && obj.bYtitl
            obj.left=3;
            obj.marginMain(1)=(obj.fontsize+obj.fontsizeMain)/2;
        elseif (~obj.bRtitl || ~strcmp(obj.rlabelLoc,'left')) && obj.bYtitl
            obj.left=2;
            obj.marginMain(1)=obj.fontsizeMain;
        elseif strcmp(obj.rlabelLoc,'left') && obj.bRtitl && ~obj.bYtitl
            obj.left=1;
            obj.marginMain(1)=obj.fontsize/2;
        end

        %% RIGHT
        obj.right=0;
        if strcmp(obj.rlabelLoc,'right') && obj.bRtitl && obj.bYtitl
            obj.right=1;
            obj.marginMain(3)=obj.fontsize;
        end

    end
    function obj=select(obj,r,c)
        bR=1;
        if ~exist('r','var') || isempty(r)
            bR=0;
        end
        bC=1;
        if ~exist('c','var') || isempty(c)
            bC=0;
        end
        if bC & bR
            obj.ha(1,r,c).select();
        else
            obj.ha.select();
        end
    end
    function obj=get_xtickLabels(obj)
        if ~isempty(obj.xtickLabels)
            obj.xtickLabels=obj.xtickLabels;
        elseif isempty(obj.xtickLabels) && ~isempty(obj.xticks)
            obj.xtickLabels=obj.xticks;
        else
            obj.xtickLabels='';
            return
        end
        if obj.bXsci
            obj.xtickLabels=cellstr(num2str(round(log10(xtickLabels(:))), '10^{%d}'));
        end
    end
    function obj=get_ytickLabels(obj)
        if ~isempty(obj.ytickLabels)
            obj.ytickLabels=obj.ytickLabels;
        elseif isempty(obj.ytickLabels) && ~isempty(obj.yticks)
            obj.ytickLabels=obj.yticks;
        else
            obj.ytickLabels='';
            return
        end
        if obj.bYsci
            obj.ytickLabels=cellstr(num2str(round(log10(ytickLabels(:))), '10^{%d}'));
        end

    end
    function obj=apply_xticks(obj)

        if ~isempty(obj.xticks)
            set(gca,'Xtick',obj.xticks);
        elseif obj.bHideXticks
            set(gca,'Xtick',[]);
        else
            set(gca,'XTickMode', 'auto')
        end

    end
    function obj=apply_yticks(obj)

        if ~isempty(obj.yticks)
            set(gca,'Ytick',obj.yticks);
        elseif obj.bHideXticks
            set(gca,'Ytick',[]);
        else
            set(gca,'YTickMode', 'auto')
            g=gca;
            obj.yextent=g.YLabel.Extent(1);
        end

    end
    function obj=apply_xtickLabels(obj,r)
        if r~=obj.nRows && obj.bHideXticks
            set(gca,'XtickLabel','');
            return
        elseif isempty(obj.xtickLabels)
            set(gca, 'XTickLabelMode', 'auto');
        else
            set(gca,'XtickLabel',obj.xtickLabels);
        end
        if ~isempty(obj.xtickFormat)
            xtickformat(obj.xtickFormat);
        end
        xtickangle(gca,obj.xtickAngle);
    end
    function obj=apply_ytickLabels(obj,c)
        if c~=1 && obj.bHideYticks
            set(gca,'YtickLabel','');
            return
        elseif isempty(obj.ytickLabels)
            set(gca, 'YTickLabelMode', 'auto');
        else
            set(gca,'YtickLabel',obj.ytickLabels);
        end
        if ~isempty(obj.ytickFormat)
            ytickformat(obj.ytickFormat);
        end
        ytickangle(gca,obj.ytickAngle);

        g=gca;
        obj.yextent=g.YLabel.Extent(1);
        if iscell(g.YTickLabel)
            obj.ytickextent=max(cellfun(@length,g.YTickLabel));
        else
            obj.ytickextent=max(length(g.YTickLabel));
        end
    end
    function obj=apply_ticks(obj,r,c)
    end
    function obj=apply_rc_labels(obj,r,c)
        if r==1 && obj.bCtitl
            obj.ha(1,r,c).title(obj.ctitl{c});
        end

        if obj.bRtitlEach && strcmp(obj.rlabelLoc,'right')
            %obj.ha(1,r,c).select();
            yyaxis right;
            yticks('');
            yticklabels('');
            ylabel(obj.rtitl{c,r},'Color',[0 0 0]);
            set(gca,'ycolor','k');
        elseif obj.bRtitlEach && strcmp(obj.rlabelLoc,'left')
            yyaxis left;
            obj.ha(1,r,c).ylabel(obj.rtitl{c,r});
        elseif c==obj.nCols && obj.bRtitl && strcmp(obj.rlabelLoc,'right')
            yyaxis right;
            %obj.ha(1,r,c).select();
            ylabel(obj.rtitl{r},'Color',[0 0 0]);

        elseif c==1 && obj.bRtitl && strcmp(obj.rlabelLoc,'left')
            obj.ha(1,r,c).ylabel(obj.rtitl{r});
        end
        yyaxis right;
        yticks('');
        yticklabels('');
        set(gca,'ycolor','k');
        yyaxis left;
        if c~=1 && obj.bHideYticks
            yticks('');
        end
    end
    function obj=apply_axis(obj)
        if ~isempty(obj.ax) && ~strcmp(obj.ax,'manual')
            axis(obj.ax);
        end
    end
    function obj=get_lims(obj)
        if obj.climRCBN=='N'
           ;
        elseif obj.bClimsFromData
            obj.get_clims_from_data();
        else
            obj.get_c_lims_from_lims();
        end

        if obj.xlimRCBN=='N'
            ;
        elseif obj.bXlimsFromData
            obj.get_x_lims_from_data();
        else
            obj.get_x_lims_from_lims();
        end

        if obj.ylimRCBN=='N'
            ;
        elseif obj.bYlimsFromData
            obj.get_y_lims_from_data();
        else
            obj.get_y_lims_from_lims();
        end
        obj.pick_lims();
    end
    function obj=get_data(obj)
        % XXX
        obj.xdata=cell(obj.nRows,obj.nCols);
        obj.ydata=cell(obj.nRows,obj.nCols);
        obj.cdata=cell(obj.nRows,obj.nCols);
        n=size(obj.RC,1);
        for i=1:n
            r=obj.RC(i,1);
            c=obj.RC(i,2);
            obj.select(r,c);
            a=f(i).Children;

            for j=1:length(a)
                x=a(j).XData;
                y=a(j).YData;
                c=a(j).CData;
                obj.xdata{r,c}=[obj.xdata{r,c}; x(:)];
                obj.ydata{r,c}=[obj.ydata{r,c}; y(:)];
                obj.cdata{r,c}=[obj.xdata{r,c}; c(:)];
            end
        end
    end
    %% FROM LIMS
    function obj=get_c_lims_from_lims(obj)
        n=size(obj.RC,1);
        obj.climsMinMax=zeros(obj.nRows,obj.nCols,2);
        for i=1:n
            r=obj.RC(i,1);
            c=obj.RC(i,2);

            obj.select(r,c);
            x=get(gca,'clim');
            obj.climsMinMax(r,c,:)=[min(x) max(x)];

        end
    end
    function obj=get_x_lims_from_lims(obj)
        n=size(obj.RC,1);
        obj.xlimsMinMax=zeros(obj.nRows,obj.nCols,2);
        for i=1:n
            r=obj.RC(i,1);
            c=obj.RC(i,2);

            obj.select(r,c);
            x=get(gca,'xlim');
            obj.xlimsMinMax(r,c,:)=[min(x) max(x)];

        end
    end
    function obj=get_y_lims_from_lims(obj)
        n=size(obj.RC,1);
        obj.ylimsMinMax=zeros(obj.nRows,obj.nCols,2);
        for i=1:n
            r=obj.RC(i,1);
            c=obj.RC(i,2);

            obj.select(r,c);
            y=get(gca,'ylim');
            obj.ylimsMinMax(r,c,:)=[min(y) max(y)];

        end
    end
    %% FROM DATA
    function obj=get_x_lims_from_data(obj)
        n=size(obj.RC,1);
        obj.xlimsMinMax=zeros(obj.nRows,obj.nCols,2);
        for i=1:n
            r=obj.RC(i,1);
            c=obj.RC(i,2);

            x=obj.xdata{r,c};
            obj.xlimsMinMax(r,c,:)=[min(x) max(x)];
        end
    end
    function obj=get_y_lims_from_data(obj)
        n=size(obj.RC,1);
        obj.ylimsMinMax=zeros(obj.nRows,obj.nCols,2);
        for i=1:n
            r=obj.RC(i,1);
            c=obj.RC(i,2);

            y=obj.ydata{r,c};
            obj.ylimsMinMax(r,c,:)=[min(y) max(y)];
        end
    end
    function obj=pick_lims(obj)

        switch obj.ylimRCBN
        case 'B'
            obj.ylimsall=[min(obj.ylimsMinMax(:)),max(obj.ylimsMinMax(:))];
        case 'R'
            obj.ylimsall=[min(obj.ylimsMinMax(:,:,1),[],2), max(obj.ylimsMinMax(:,:,2),[],2)];
        case 'C'
            obj.ylimsall=[min(obj.ylimsMinMax(:,:,1),[],1); max(obj.ylimsMinMax(:,:,2),[],1)];
        end

        switch obj.xlimRCBN
        case 'B'
            obj.xlimsall=[min(obj.xlimsMinMax(:)),max(obj.xlimsMinMax(:))];
        case 'R'
            obj.xlimsall=[min(obj.xlimsMinMax(:,:,1),[],2), max(obj.xlimsMinMax(:,:,2),[],2)];
        case 'C'
            obj.xlimsall=[min(obj.xlimsMinMax(:,:,1),[],1); max(obj.xlimsMinMax(:,:,2),[],1)];
        end

        switch obj.climRCBN
        case 'B'
            obj.climsall=[min(obj.climsMinMax(:)),max(obj.climsMinMax(:))];
        case 'R'
            obj.climsall=[min(obj.climsMinMax(:,:,1),[],2), max(obj.climsMinMax(:,:,2),[],2)];
        case 'C'
            obj.climsall=[min(obj.climsMinMax(:,:,1),[],1); max(obj.climsMinMax(:,:,2),[],1)];
        end
    end

    function obj=apply_lim(obj,r,c)

        switch obj.xlimRCBN
        case 'N'
            xlims=obj.xlim;
        case 'B'
            xlims=obj.xlimsall;
        case 'R'
            xlims=obj.xlimsall(r,:);
        case 'C'
            xlims=transpose(obj.xlimsall(:,c));
        end

        switch obj.ylimRCBN
        case 'N'
            ylims=obj.ylim;
        case 'B'
            ylims=obj.ylimsall;
        case 'R'
            ylims=obj.ylimsall(r,:);
        case 'C'
            ylims=transpose(obj.ylimsall(:,c));
        end

        switch obj.climRCBN
        case 'N'
            clims=obj.clim;
        case 'B'
            clims=obj.climsall;
        case 'R'
            clims=obj.climsall(r,:);
        case 'C'
            clims=transpose(obj.climsall(:,c));
        end

        if strcmp(obj.yscale,'log')
            ylims(ylims < 0)=0;
        end
        if strcmp(obj.xscale,'log')
            xlims(xlims < 0)=0;
        end

        if ~isempty(obj.xlimSpace)
            xlims=getLims(xlims,obj.xlimSpace);
        end
        if ~isempty(obj.ylimSpace)
            ylims=getLims(ylims,obj.ylimSpace);
        end

        if ~isempty(xlims)
            set(gca,'xlim',xlims);
        end
        if ~isempty(ylims)
            set(gca,'ylim',ylims);
        end
        if ~isempty(clims)
            caxis(clims);
            %set(gca,'clim',clims);
        end
    end
    function obj=apply_titles(obj)
        %obj.select(1);
        %obj.sgt=sgtitle([obj.titl newline],'fontsize',obj.fontsizeMain);
        obj.ha(1).title([obj.titl newline]);
        %obj.ha.title(obj.titl);

        if obj.xtickAngle>30
            n=2;
        elseif obj.xtickAngle>0
            n=1;
        else
            n=0;
        end
        obj.ha(1).xlabel([repmat(newline,1,n) obj.xtitl]);

        % HERE
        %obj.yextent
        %obj.ytickextent
        n=0;
        if obj.yextent > -1
            n=n+1;
        elseif obj.yextent < -10
            n=n-1;
        end
        if obj.ytickextent > 4
            n=n+1;
        end
        if n < 0
            n=0;
        end
        obj.ha(1).ylabel([obj.ytitl repmat(newline,1,n)]);

    end
    function obj=c(obj)
        obj.finalize();
    end
    function obj=finalize(obj,bBreak)
        if ~exist('bBreak')
            bBreak=0;
        end
        obj.get_lims();
        for i=1:size(obj.RC,1)
            r=obj.RC(i,1);
            c=obj.RC(i,2);
            obj.select(r,c);


            box on;
            set(gcf,'color','w');
            set(gca,'TitleFontWeight','normal');
            set(gca,'fontWeight','normal');
            try set(gca,'XColor','k'); catch, end
            try set(gca,'YColor','k'); catch, end

            obj.apply_scale();

            obj.apply_lim(r,c);
            obj.apply_font(r,c);
            obj.apply_axis; % XXX
            obj.apply_rc_labels(r,c);

            obj.apply_xticks();
            obj.apply_xtickLabels(r);
            obj.apply_yticks();
            obj.apply_ytickLabels(c);

            if obj.bImg
                colormap gray;
                grid off;
            end
            if obj.bRotateRlabel && obj.bRtitl && ((obj.bRtitlEach) || (strcmp(obj.rlabelLoc,'right') && c==obj.nCols) ||  (strcmp(obj.rlabelLoc,'left') && c==1))
                obj.rotate_rlabel(r,c);
            end
        end
        obj.apply_position();
        obj.apply_titles();


        %if obj.bRotateRlabel && obj.bRtitl
        %    obj.rotate_r_labels();
        %end
        drawnow
    end
    function obj=apply_scale(obj)
        if ~isempty(obj.xscale)
            set(gca,'Xscale',obj.xscale);
        end
        if ~isempty(obj.yscale)
            set(gca,'Yscale',obj.yscale);
        end
    end
    function obj=apply_font(obj,r,c)
        obj.ha(1,r,c).fontsize=obj.fontsize;
    end
    function obj=apply_position(obj)
        set(gcf,'Position',obj.position);
        warning('on','panel:PanelZeroSize');
        %drawnow
        %F=get(gcf);
        %obj.apply_left(F);
        %obj.apply_right(F);
        %obj.apply_bottom(F);
        %obj.apply_top(F);

        %drawnow
    end

    function obj=rotate_rlabel(obj,r,c)

        %yyaxis right
        T=get(gca,'YLabel');
        if strcmp(T.String,'')
            return
        end
        T.Rotation=-90;
        T.Units='point';

        p=T.Position;
        p(1)=p(1)+obj.fontsize;

        T.Position=p;
        set(gca,'YLabel',T);
    end
    function obj=apply_left(obj,F)
        if obj.left==0
            return
        end
        T=F.Children(1).YLabel;
        T.Units='point';
        p=T.Position;
        if obj.left==3
            p(1)=p(1)-obj.fontsize*2;
        elseif obj.left==2
            p(1)=p(1)-obj.fontsize/2;
        end
        set(T,'Position',p);
    end

    function obj=apply_right(obj,F)
        if obj.right==0
            return
        end
        T=F.Children(1).YLabel;
        T.Units='point';
        p=T.Position;
        if obj.right==1
            p(1)=p(1)-obj.fontsize/2;
        end
        set(T,'Position',p);
    end

    function obj=apply_bottom(obj,F)
        if obj.bottom==0
            return
        end
        T=F.Children(1).XLabel;
        T.Units='point';
        p=T.Position;
        if obj.bottom==3
            %% 0 = above bottom plot line
            p(2)=0-obj.fontsizeMain-obj.fontsize; % .02
        else
            p(2)=p(2)-obj.fontsize/2;
        end
        set(T,'Position',p);
    end

    function obj=apply_top(obj,F)
        if obj.bottom==0
            return
        end
        T=F.Children(1).Title;
        T.Units='point';
        p=T.Position;
        if ~isempty(obj.ytitl) && ( ~isempty(obj.rtitl) || obj.bHideYticks)
            p(2)=p(2)+obj.fontsize*2;
        end
        set(T,'Position',p);
    end

end
end
