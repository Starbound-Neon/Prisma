localfirstupdate = true

function init(...)
    sb.logInfo("Test init")
end

function update(...)
    if localfirstupdate then
        localfirstupdate = false
        if tech and localAnimator then
            sb.logInfo("Tables loaded successful!")
        end
    end
end

function uninit(...)
    sb.logInfo("Test uninit")
end
